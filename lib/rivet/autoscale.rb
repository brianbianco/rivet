module Rivet
  class Autoscale

    REQUIRED_FIELDS = [:min_size,:max_size,:launch_configuration,:availability_zones] 

    attr_reader :min_size, :max_size, :name, :launch_configuration
    attr_reader :availability_zones, :tags

    def initialize(name,definition)
      @name = name
      @min_size = definition['min_size']
      @max_size = definition['max_size']

      if definition.has_key?('tags')
        definition['tags'].each do |t|
          unless t.has_key?('propagate_at_launch')
            t['propagate_at_launch'] = true
          end
        end
        @tags = definition['tags']
      else
        @tags = Array.new
      end
      @launch_config = LaunchConfig.new(definition)

      # Normalizing zones to match what the SDK expects, E.G. "<region><zone>"
      @availability_zones = definition['availability_zones'].map! do |zone|
        definition['region'] + zone
      end

      # The launch_configuration attr exists for convinence since that is what
      # the aws SDK refers to the launch configuration name as for autoscaling
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

      Rivet::Log.write(level, "Remote and local defintions match") unless differences?

      differences.each_pair do |attr,values|
        Rivet::Log.write(level,"#{attr}:")
        Rivet::Log.write(level,"  remote: #{values['remote']}")
        Rivet::Log.write(level,"  local:  #{values['local']}")
      end
    end

    def sync
      if differences?
        Rivet::Log.info("Syncing autoscale group changes to AWS for #{@name}")
        autoscale = AWS::AutoScaling.new()
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
      options = Hash.new
      differences.each_pair do |attribute,values|
        options[attribute.to_sym] = values['local']
      end

      REQUIRED_FIELDS.each do |field|
        unless options.has_key?(field)
          options[field] = self.send(field)
        end
      end
      options
    end

    def get_differences
      remote = get_remote
      differences = Hash.new
      [:min_size,:max_size,:launch_configuration,:tags].each do |a|
        if remote[a.to_s] != self.send(a)
          differences[a.to_s] = { 'remote' => remote[a.to_s], 'local' => self.send(a) }
        end
      end

      if remote['availability_zones'] != availability_zones
        differences['availability_zones'] = { 'remote' => remote['availability_zones'], 'local' => availability_zones }
      end if remote.has_key?('availability_zones')

      differences
    end

    protected

    def get_remote
      autoscale = AWS::AutoScaling.new()
      remote_group = autoscale.groups[@name]
      if remote_group.exists?

        remote_hash = [:min_size,:max_size].inject(Hash.new) do |accum,attr|
          accum[attr.to_s] = remote_group.send(attr)
          accum
        end

        # {:resource_id=>"venus", :propagate_at_launch=>true, :value=>"Venus", :key=>"Name", :resource_type=>"auto-scaling-group"}
        remote_hash['tags'] = remote_group.tags.to_a.inject(Array.new) do |tags,current|
          tags << normalize_tag(current)
        end

        remote_hash['launch_configuration'] = remote_group.launch_configuration_name

        # Normalize their AWS::Core::Data::List to a sorted array
        remote_hash['availability_zones'] = remote_group.availability_zone_names.to_a.sort

        remote_hash
      else
        { }
      end
    end

    def create(options)
      autoscale = AWS::AutoScaling.new()
      if autoscale.groups[@name].exists?
        raise "Cannot create AutoScaling #{@name} group it already exists!"
      else
        autoscale.groups.create(@name,options)
      end
    end

    def normalize_tag(tag)
      normalized_tag = Hash.new
      tag.each_pair do |k,v|
        unless (k == :resource_id || k == :resource_type)
          normalized_tag[k.to_s] = v
        end
      end
      normalized_tag
    end

  end
end
