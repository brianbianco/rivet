# encoding: UTF-8

module Rivet
  module AwsUtils

    def self.verify_security_groups(groups)
      return false if groups.nil? || groups.all?{|g| g.match(/\Asg-[0-9a-f]{8}\z/) }
      Rivet::Log.info "Verifying security groups: #{groups.join(",")}"

      security_groups_collection = AWS::EC2.new.security_groups
      filtered_groups = []
      security_groups_collection.filter('group-name', *groups).each do |g|
        filtered_groups << g.name
      end

      groups.each do |g|
        unless filtered_groups.include?(g)
          Rivet::Log.debug "Creating security group #{g}"
          security_groups_collection.create g
        end
      end
    end

    def self.parse_profile_text(text)
      current_profile = nil
      profile_matcher = /^\[(profile+\s)?(\w+)\]/
      option_matcher  = /(\w.*)\s*=\s*(\S.*)\s*/
      aws_config      = {}

      text.each_line do |line|
        if line =~ profile_matcher
          current_profile = line.match(profile_matcher)[2]
          aws_config[current_profile] = {} unless aws_config.has_key?(current_profile)
        end

        if line =~ option_matcher && !current_profile.nil?
          results = line.match(option_matcher)

          # Normalize the option name so it can be used with the AWS SDK
          if results[1] =~ /^\S*aws_/
            option = results[1].strip.gsub('aws_', '').to_sym
          else
            option = results[1].strip.to_sym
          end

          value = results[2].strip
          aws_config[current_profile].merge!({ option => value })
        end
      end
      aws_config
    end

    def self.config_parser
      if ENV['AWS_CONFIG_FILE']
        parse_profile_text(File.read(ENV['AWS_CONFIG_FILE']))
      end
    end

    def self.set_aws_credentials(profile)
      Rivet::Log.info "Settings AWS credentials to #{profile} profile"
      settings = config_parser
      aws_creds = nil

      if settings && settings.has_key?(profile)
        aws_creds = [:access_key_id, :secret_access_key, :region].inject({})do |accum, option|
          if settings[profile].has_key?(option)
            accum[option] = settings[profile][option]
          end
          accum
        end
        AWS.config(aws_creds) if aws_creds
      end
    end
  end
end
