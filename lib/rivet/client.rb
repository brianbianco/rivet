module Rivet
  class Client
    def initialize
    end

    def run(options)
      AwsUtils.set_aws_credentials(options[:profile])
      Rivet::Log.level(options[:log_level])
      Rivet::Utils.ensure_minimum_setup

      group_def = Rivet::Utils.get_definition(options[:group])

      Rivet::Utils.die "The #{options[:group]} definition doesn't exist" unless group_def

      Rivet::Log.info("Checking #{options[:group]} autoscaling definition")
      autoscale_def = Rivet::Autoscale.new(options[:group],group_def)
      autoscale_def.show_differences

      if options[:sync]
        autoscale_def.sync
      else
        Rivet::Log.info("use the -s [--sync] flag to sync changes")
      end

    end

  end
end

