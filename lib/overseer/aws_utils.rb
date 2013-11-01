module Overseer
  module AwsUtils
    # A whole bunch of annoying code to get AWS credentials goes here.

    # Faking it for now
    AWS.config()

    def verify_security_groups(groups)
      Overseer::Log.info("Verifying security groups: #{groups.join(",")}")

      security_groups_collection = AWS::EC2.new().security_groups
      filtered_groups = Array.new
      security_groups_collection.filter('group-name', *groups).each do |g|
        filtered_groups << g.name
      end

      security_groups.each do |g|
        unless filtered_groups.include?(g)
          Overseer::Log.debug("Creating security group #{g}")
          security_groups_collection.create g
        end
      end
    end

  end
end
