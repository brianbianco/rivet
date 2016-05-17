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
      :elastic_ips,
      :iam_instance_profile,
      :image_id,
      :instance_initiated_shutdown_behavior,
      :instance_type,
      :kernel_id,
      :key_name,
      :key_pair,
      :monitoring_enabled,
      :network_interfaces,
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
    attr_reader :post

    def initialize(config)
      @ec2 = AWS::EC2.new
      @name = config.name
      @post = config.post
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
      eips_to_add    = server_options.delete :elastic_ips
      enis_to_add    = server_options.delete :network_interfaces
      instances      = @ec2.instances.create server_options

      # Since create returns either an instance object or an array let us
      # just go ahead and make that more sane
      instances = [instances] unless instances.respond_to? :each

      ready_instances = wait_until_running instances
      add_tags(ready_instances,tags_to_add)
      add_eips(ready_instances,eips_to_add) if eips_to_add
      add_network_interfaces(ready_instances,enis_to_add) if enis_to_add
      unless post.nil?
        post_processing = OpenStruct.new
        post_processing.instances = ready_instances.collect { |i| i.id }
        post_processing.instance_eval(&post)
      end
    end

    protected

    def add_network_interfaces(instances,interfaces)
      index_to_instances = 0
      interfaces.each do |i|
        unless index_to_instances > instances.size
          attach_interface(instances[index_to_instances],i)
          index_to_instances + 1
        end
      end
    end

    def attach_interface(instance,interface)
      eni = AWS::EC2::NetworkInterface.new(interface)
      if eni.exists?
        Rivet::Log.info "Attaching #{eni.id} to #{instance.id}"
        instance.attach_network_interface eni
      end
    end

    def add_eips(instances,eips_to_add)
      index_to_instances = 0
      eips_to_add.each do |ip|
        unless index_to_instances > instances.size
          attach_ip(instances[index_to_instances],ip)
          index_to_instances + 1
        end
      end
    end

    def attach_ip(instance,ip)
      eip = AWS::EC2::ElasticIp.new(ip)
      if eip.exists?
        Rivet::Log.info "Attaching #{eip} to #{instance.id}"
        instance.associate_elastic_ip eip
      end
    end

    def tag_instance(instance,tags_to_add)
      tags_to_add.each do |t|
        @ec2.tags.create(instance, t[:key].to_s, :value => t[:value])
      end
    end

    def add_tags(instances,tags_to_add)
      instances.each do |i|
        if tags_to_add
          tag_instance(i,tags_to_add)
        else
          Rivet::Log.info "No tags in config, defaulting to Name: #{@name}"
          tag_instance(i,[{ :key => 'Name', :value => @name }])
        end
      end
    end

    def wait_until_running(instances)
      #TODO: Catch AWS::EC2::Errors::InvalidInstanceID::NotFound and only bomb out if it happens many times

      Rivet::Log.info "Waiting for instance to start.  This could take a while..."
      finished = []
      until instances.size <= 0
        instances.reject! do |i|
          unless i.status == :pending
            Rivet::Log.info "#{i.id} is in #{i.status} state."
            finished << i
            true
          end
        end
        sleep 1
      end
      finished
    end
  end
end
