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
      @name = config.name

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

    def sync
      create(options)
    end

    def options
      @options ||= get_options
    end

    def get_options
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

    protected

    def create(options)
      ec2 = AWS::EC2.new

      # The AWS ruby SDK forces you to apply tags AFTER creation
      # This option must be removed so the create call doesn't blow up.
      tags_to_add = options.delete :tags

      i = ec2.instances.create options

      if tags_to_add
        tags_to_add.each do |t|
          ec2.tags.create(i, t[:key].to_s, :value => t[:value])
        end
      else
        ec2.tags.create(i,'Name',@name)
      end
    end

  end
end
