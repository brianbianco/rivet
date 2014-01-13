module Rivet
  class Client
    def run(options)
      AwsUtils.set_aws_credentials(options.profile)
      Rivet::Log.level(options.log_level)

      unless Dir.exists?(options.config_path)
        Rivet::Utils.die "The autoscale config path doesn't exist"
      end

      # Get config object for autoscaling group
      config = Rivet::Utils.get_config(
        options.group,
        options.config_path)

      unless config
        Rivet::Utils.die "The #{options.group} autoscale definition doesn't exist"
      end

      config.validate

      Rivet::Log.info "Checking #{options.group} autoscaling definition"
      autoscale_group = Rivet::Autoscale.new(config)
      autoscale_group.show_differences

      if options.sync
        autoscale_group.sync
      else
        Rivet::Log.info "use the -s [--sync] flag to sync changes"
      end
    end
  end
end
