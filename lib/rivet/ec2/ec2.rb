# encoding: UTF-8

module Rivet
  class Ec2
    OPTIONS = [
      :associate_public_ip_address,
      :availability_zone,
      :block_device_mappings,
      :count,
      :dedicated_tenancy,
      :disable_api_termination,
      :ebs_optimized,
      :iam_instance_profile,
      :image_id,
      :instance_initiated_shutdown_behavior,
      :instance_type,
      :kernel_id,
      :key_name,
      :key_pair,
      :monitoring_enabled,
      :placement_group,
      :private_ip_address,
      :ramdisk_id,
      :security_group_ids,
      :security_groups,
      :subnet,
      :tags,
      :user_data
    ].each { |a| attr_reader a }

    REQUIRED_OPTIONS = [
      :image_id
    ]

    attr_reader :name

    def initialize(config)
      @ec2 = AWS::EC2.new
      @name = config.name
      @user_data = Bootstrap.new(config).user_data

      OPTIONS.each do |o|
        if config.respond_to?(o)
          instance_variable_set("@#{o}", config.send(o))
        end
      end
    end

    def display(level = 'info')
      options.each_pair do |attr, values|
        Rivet::Log.write(level, "  #{attr}: #{values}")
      end
    end

    def options
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

    def sync
      # The AWS ruby SDK forces you to apply tags AFTER creation
      # This option must be removed so the create call doesn't blow up.
      server_options = options
      tags_to_add    = server_options.delete :tags
      i              = @ec2.instances.create server_options

      # Since create returns either an instance object or an array let us
      # just go ahead and make that more sane
      i = [i] unless i.respond_to? :each

      i.each do |instance|
        if tags_to_add
          add_tags(instance,tags_to_add)
        else
          Rivet::Log.info "No tags in config, defaulting to Name: #{@name}"
          add_tags(instance,[{ :key => 'Name', :value => @name }])
        end
      end

    end

    def add_tags(instance,tags_to_add)
      tags_to_add.each do |t|
        @ec2.tags.create(instance, t[:key].to_s, :value => t[:value])
      end
    end
  end
end
