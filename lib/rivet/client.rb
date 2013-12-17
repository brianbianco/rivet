module Rivet
  class Client
    def initialize
    end

    def run(options)
      AwsUtils.set_aws_credentials(options.profile)
      Rivet::Log.level(options.log_level)

      unless Dir.exists?(options.definitions_directory)
        Rivet::Utils.die("The autoscale definitions directory doesn't exist")
      end

      definition = Rivet::Utils.get_definition(
        options.group,
        options.definitions_directory)

      unless definition
        Rivet::Utils.die "The #{options.group} definition doesn't exist"
      end

      Rivet::Log.info("Checking #{options.group} autoscaling definition")
      autoscale_def = Rivet::Autoscale.new(options.group, definition)
      autoscale_def.show_differences

      if options.sync
        autoscale_def.sync
      else
        Rivet::Log.info("use the -s [--sync] flag to sync changes")
      end

      exitstatus = 0
    end

  end
end
