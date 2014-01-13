module Rivet
  class Autoscale

    OPTIONS = [
      :availability_zones,
      :default_cooldown,
      :desired_capacity,
      :health_check_grace_period,
      :health_check_type,
      :launch_configuration,
      :load_balancers,
      :max_size,
      :min_size,
      :placement_group,
      :subnets,
      :tags,
      :termination_policies
    ].each { |a| attr_reader a }

    REQUIRED_OPTIONS = [
      :availability_zones,
      :launch_configuration,
      :max_size,
      :min_size,
    ]

    attr_reader :name

    def initialize(config)
      @name       = config.name

      OPTIONS.each do |o|
        instance_variable_set("@#{o}",config.send(o)) if config.respond_to?(o)
      end

      if config.respond_to?(:tags)
        config.tags.each do |t|
          unless t.has_key? 'propagate_at_launch'
            t['propagate_at_launch'] = true
          end
        end
        @tags = config.tags
      else
        @tags = []
      end
      @launch_config = LaunchConfig.new(config)

      # Normalizing zones to match what the SDK expects, E.G. "<region><zone>"
      @availability_zones = config.availability_zones.map { |zone| "#{config.region}#{zone}" }

      # The launch_configuration attr exists because that is what
      # the aws SDK refers to the launch configuration name as.
      @launch_configuration = @launch_config.identity
    end

    def options
      @options ||= get_update_options
    end

    def differences
      @differences ||= get_differences
    end

    def differences?
      !differences.empty?
    end

    def show_differences(level = 'info')
      Rivet::Log.write(level, "Remote and local match") unless differences?
      differences.each_pair do |attr, values|
        Rivet::Log.write(level, "#{attr}:")
        Rivet::Log.write(level, "  remote: #{values['remote']}")
        Rivet::Log.write(level, "  local:  #{values['local']}")
      end
     Rivet::Log.write('debug',@launch_config.user_data)
    end

    def sync
      if differences?
        Rivet::Log.info("Syncing autoscale group changes to AWS for #{@name}")
        autoscale = AWS::AutoScaling.new
        group = autoscale.groups[@name]

        @launch_config.save
        create(options) unless group.exists?

        Rivet::Log.debug("Updating autoscaling group with the follow options")
        Rivet::Log.debug(options.inspect)

        group.update(options)
      else
        Rivet::Log.info("No autoscale differences to sync to AWS for #{@name}.")
      end
    end

    protected

    def get_update_options
      options = {}
      differences.each_pair do |attribute, values|
        options[attribute.to_sym] = values['local']
      end

      REQUIRED_OPTIONS.each do |field|
        unless options.has_key? field
          options[field] = self.send(field)
        end
      end
      options
    end

    def get_differences
      remote = get_remote
      differences = {}
      OPTIONS.each do |a|
        if remote[a.to_s] != self.send(a)
          differences[a.to_s] = { 'remote' => remote[a.to_s], 'local' => self.send(a) }
        end
      end

      differences
    end

    def get_remote
      autoscale = AWS::AutoScaling.new
      remote_group = autoscale.groups[@name]
      if remote_group.exists?
        remote_hash = OPTIONS.inject({}) do |accum, attr|
          if respond_to?("normalize_#{attr}".to_sym)
            accum[attr.to_s] = send("normalize_#{attr}".to_sym,remote_group)
          else
            accum[attr.to_s] = remote_group.send attr
          end
          accum
        end

        remote_hash
      else
        {}
      end
    end

    def create(options)
      autoscale = AWS::AutoScaling.new
      if autoscale.groups[@name].exists?
        raise "Cannot create AutoScaling #{@name} group it already exists!"
      else
        autoscale.groups.create(@name, options)
      end
    end

    protected

    def normalize_launch_configuration(group)
      group.launch_configuration_name
    end

    def normalize_load_balancers(group)
      group.load_balancers.to_a.sort
    end

    def normalize_availability_zones(group)
      group.availability_zone_names.to_a.sort
    end

    def normalize_tags(group)
      group.tags.to_a.inject([]) do |normalized_tags,current|
        normalized_tags << normalize_tag(current)
      end
    end

    def normalize_subnets(group)
      group.subnets.to_a.sort
    end

    def normalize_termination_policies(group)
      group.termination_policies.to_a.sort
    end

    def normalize_tag(tag)
      normalized_tag = {}
      tag.each_pair do |k, v|
        unless (k == :resource_id || k == :resource_type)
          normalized_tag[k.to_s] = v
        end
      end
      normalized_tag
    end

  end
end
