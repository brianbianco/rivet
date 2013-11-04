module Overseer
  class Client
    def initialize
    end

    def run(options)
      AwsUtils.set_aws_credentials(options[:profile])
      Overseer::Log.level(options[:log_level])
      Overseer.ensure_minimum_setup

      group_def = Overseer.get_definition(options[:group])
      Overseer::Log.info("Checking #{options[:group]} autoscaling definition")
      autoscale_def = Overseer::Autoscale.new(options[:group],group_def)
      autoscale_def.show_differences

      if options[:sync]
        autoscale_def.sync
      else
        Overseer::Log.info("use the -s [--sync] flag to sync changes")
      end

    end

  end
end

