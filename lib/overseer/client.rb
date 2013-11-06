module Overseer
  class Client
    def initialize
    end

    def run(options)
      AwsUtils.set_aws_credentials(options[:profile])
      Overseer::Log.level(options[:log_level])
      Overseer::Utils.ensure_minimum_setup

      group_def = Overseer::Utils.get_definition(options[:group])

      Overseer::Utils.die "The #{options[:group]} definition doesn't exist" unless group_def

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

