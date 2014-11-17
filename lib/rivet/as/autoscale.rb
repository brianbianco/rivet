# encoding: UTF-8

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
      :min_size
    ]

    attr_reader :name

    def initialize(config)
      @name          = config.name
      @remote_group  = AwsAutoscaleWrapper.new(@name)
      @launch_config = LaunchConfig.new(config)

      OPTIONS.each do |o|
        if config.respond_to?(o)
          instance_variable_set("@#{o}", config.send(o))
        end
      end

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
      Rivet::Log.write(level, 'Remote and local match') unless differences?
      differences.each_pair do |attr, values|
        Rivet::Log.write(level, "#{attr}:")
        Rivet::Log.write(level, "  remote: #{values[:remote]}")
        Rivet::Log.write(level, "  local:  #{values[:local]}")
      end
     Rivet::Log.write('debug', @launch_config.user_data)
    end

    def sync
      if differences?
        Rivet::Log.info "Syncing autoscale group changes to AWS for #{@name}"
        autoscale = AWS::AutoScaling.new
        group = autoscale.groups[@name]

        @launch_config.save
        create(options) unless group.exists?

        Rivet::Log.debug 'Updating autoscaling group with the follow options'
        Rivet::Log.debug options.inspect

        # It's easier to just delete all the tags if there are changes and apply
        # new ones, than ferret out exactly which ones should be removed.
        if differences.has_key? :tags
          group.delete_all_tags
        end
        group.update(options)

      else
        Rivet::Log.info "No autoscale differences to sync to AWS for #{@name}."
      end
    end

    protected

    def get_differences
      differences = {}

      OPTIONS.each do |o|
        remote_value = @remote_group.send(o)
        local_value = send(o)

        if (remote_value != local_value)
          differences[o] = { :local => send(o), :remote => @remote_group.send(o) }
        end
      end
      differences
    end

    def get_update_options
      options = {}

      OPTIONS.each do |field|
        local_value = self.send(field)
        options[field] = local_value unless local_value.nil?
      end

      REQUIRED_OPTIONS.each do |field|
        unless options.has_key? field
          options[field] = self.send(field)
        end
      end
      options
    end

    def create(options)

      # When creating an autoscaling group passing empty arrays for subnets
      # or some other fields can cause it to barf.  Remove them first.
      options.delete_if { |k, v| v.respond_to?(:'empty?') && v.empty? }

      Rivet::Log.debug "Creating Autoscaling group #{@name} with the following options"
      Rivet::Log.debug options

      autoscale = AWS::AutoScaling.new
      if autoscale.groups[@name].exists?
        fail "Cannot create AutoScaling #{@name} group it already exists!"
      else
        autoscale.groups.create(@name, options)
      end
    end

  end
end
