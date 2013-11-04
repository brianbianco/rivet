module Overseer
  class LaunchConfig

    LC_ATTRIBUTES = ['key_name','image_id','instance_type','security_groups','bootstrap']

    LC_ATTRIBUTES.each do |a|
      attr_reader a.to_sym
    end

    def initialize(spec)
      LC_ATTRIBUTES.each do |a|

        if respond_to? "normalize_#{a}".to_sym
          spec[a] = self.send("normalize_#{a.to_sym}",spec[a])
        end

        instance_variable_set("@#{a}",spec[a])
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

      lc_collection = AWS::AutoScaling.new().launch_configurations

      if lc_collection[identity].exists?
        Overseer::Log.info("Launch configuration #{identity} already exists in AWS")
      else
        options = { :key_pair => key_name, :security_groups => security_groups, :user_data => user_data}
        Overseer::Log.info("Saving launch configuration #{identity} to AWS")
        Overseer::Log.debug("Launch Config options:\n #{options.inspect}")
        lc_collection.create(identity,image_id,instance_type, options)
      end
    end

    protected

    def generate_identity
      identity = LC_ATTRIBUTES.inject({}) do |ident_hash,attribute|
        if attribute != 'bootstrap'
          Overseer::Log.debug("Adding #{attribute} : #{self.send(attribute.to_sym)} to identity hash for LaunchConfig")
          ident_hash[attribute] = self.send(attribute.to_sym)
        else
          Overseer::Log.debug("Adding user_data to identity hash for LaunchConfig:\n#{user_data} ")
          ident_hash[attribute] = user_data
        end
        ident_hash
      end
      Digest::SHA1.hexdigest(Marshal::dump(identity))
    end

    def normalize_security_groups(groups)
      groups.sort!
    end

  end
end

