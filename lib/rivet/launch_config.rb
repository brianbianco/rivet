module Rivet
  class LaunchConfig

    LC_ATTRIBUTES = %w(key_name image_id instance_type security_groups iam_instance_profile bootstrap)

    LC_ATTRIBUTES.each do |a|
      attr_reader a.to_sym
    end

    attr_reader :id_prefix

    def initialize(spec,id_prefix = 'rivet_')
      @id_prefix = id_prefix

      LC_ATTRIBUTES.each do |a|

        if respond_to? "normalize_#{a}".to_sym
          spec[a] = self.send("normalize_#{a.to_sym}", spec[a])
        end

        Rivet::Log.debug("Setting LaunchConfig @#{a} to #{spec[a]}")
        instance_variable_set("@#{a}", spec[a])
      end
    end

    def user_data
      @user_data ||= Bootstrap.new(bootstrap).user_data
    end

    def identity
      @identity ||= generate_identity
    end

    def save
      AwsUtils.verify_security_groups(security_groups)

      lc_collection = AWS::AutoScaling.new.launch_configurations

      if lc_collection[identity].exists?
        Rivet::Log.info("Launch configuration #{identity} already exists in AWS")
      else
        options = {}
        options[:key_pair]              = key_name              unless key_name.nil?
        options[:security_groups]       = security_groups       unless security_groups.nil?
        options[:user_data]             = user_data             unless user_data.nil?
        options[:iam_instance_profile]  = iam_instance_profile  unless iam_instance_profile.nil?

        Rivet::Log.info("Saving launch configuration #{identity} to AWS")
        Rivet::Log.debug("Launch Config options:\n #{options.inspect}")
        lc_collection.create(identity, image_id, instance_type, options)
      end
    end

    protected

    def build_identity_string
      identity = LC_ATTRIBUTES.inject('') do |accum, attribute|
        if attribute != 'bootstrap'
          attr_value = self.send(attribute.to_sym) ? self.send(attribute.to_sym) : "\0"
          attr_value = attr_value.join("\t") if attr_value.respond_to? :join
          accum << attribute.to_s
          accum << Base64.encode64(attr_value)
        else
          accum << attribute.to_s
          accum << Base64.encode64(user_data ? user_data : "\0")
        end
        accum
      end
      Rivet::Log.debug("Pre SHA1 identity string is #{identity}")
      identity
    end

    def generate_identity
      @id_prefix + Digest::SHA1.hexdigest(build_identity_string)
    end

    def normalize_security_groups(groups)
      groups.nil? ? groups : groups.sort
    end

  end
end
