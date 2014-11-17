# encoding: UTF-8

module Rivet
  class LaunchConfig

    ATTRIBUTES = [
      :bootstrap,
      :iam_instance_profile,
      :image_id,
      :instance_type,
      :key_name,
      :security_groups,
      :associate_public_ip_address,
      :detailed_instance_monitoring,
      :block_device_mappings,
      :kernel_id,
      :ramdisk_id,
      :spot_price
    ].each { |a| attr_reader a }

    attr_reader :id_prefix, :config

    def initialize(config, id_prefix = 'rivet_')
      @config    = config
      @id_prefix = id_prefix

      ATTRIBUTES.each do |a|
        if config.respond_to?(a)
          Rivet::Log.debug "Setting LaunchConfig @#{a} to #{config.send(a)}"
          instance_variable_set("@#{a}", config.send(a))
        end
      end
    end

    def user_data
      @user_data ||= Bootstrap.new(@config).user_data
    end

    def identity
      @identity ||= generate_identity
    end

    def save
      AwsUtils.verify_security_groups(security_groups)

      lc_collection = AWS::AutoScaling.new.launch_configurations

      if lc_collection[identity].exists?
        Rivet::Log.info "Launch configuration #{identity} already exists in AWS"
      else
        options = {}
        options[:key_pair]                      = key_name                      unless key_name.nil?
        options[:security_groups]               = security_groups               unless security_groups.nil?
        options[:user_data]                     = user_data                     unless user_data.nil?
        options[:iam_instance_profile]          = iam_instance_profile          unless iam_instance_profile.nil?
        options[:associate_public_ip_address]   = associate_public_ip_address   unless associate_public_ip_address.nil?
        options[:detailed_instance_monitoring]  = detailed_instance_monitoring  unless detailed_instance_monitoring.nil?
        options[:block_device_mappings]         = block_device_mappings         unless block_device_mappings.nil?
        options[:kernel_id]                     = kernel_id                     unless kernel_id.nil?
        options[:ramdisk_id]                    = ramdisk_id                    unless ramdisk_id.nil?
        options[:spot_price]                    = spot_price                    unless spot_price.nil?

        Rivet::Log.info "Saving launch configuration #{identity} to AWS"
        Rivet::Log.debug "Launch Config options:\n #{options.inspect}"
        lc_collection.create(identity, image_id, instance_type, options)
      end
    end

    protected

    def build_identity_string
      identity = ATTRIBUTES.inject('') do |accum, attribute|
        if attribute != :bootstrap
          attr_value = self.send(attribute) ? self.send(attribute) : "\0"
          attr_value = attr_value.join("\t")  if attr_value.respond_to? :join
          attr_value = attr_value.to_s        if !!attr_value == attr_value
          accum << attribute.to_s
          accum << Base64.encode64(attr_value)
        else
          accum << attribute.to_s
          accum << Base64.encode64(user_data ? user_data : "\0")
        end
        accum
      end
      identity
    end

    def generate_identity
      @id_prefix + Digest::SHA1.hexdigest(build_identity_string)
    end

  end
end
