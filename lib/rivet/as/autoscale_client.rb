# encoding: UTF-8

module Rivet
  class AutoscaleClient
    def run(options)
      AwsUtils.set_aws_credentials options.profile
      Rivet::Log.level options.log_level

      Rivet::Log.info "Using autoscale config path #{options.config_path}"

      unless Dir.exists?(options.config_path)
        Rivet::Utils.die 'The autoscale config path does not exist'
      end

      # Get config object for autoscaling group
      config = Rivet::Utils.get_autoscale_config(
        options.group,
        options.config_path)

      unless config
        Rivet::Utils.list_groups(options.config_path)
        Rivet::Utils.die "The #{options.group} autoscale definition doesn't exist"
      end

      config.validate

      config = ConfigProxy.new(config)

      Rivet::Log.info "Checking #{options.group} autoscaling definition"

      autoscale_group = Rivet::Autoscale.new(config)
      autoscale_group.show_differences

      if options.sync
        autoscale_group.sync
      else
        Rivet::Log.info 'use the -s [--sync] flag to sync changes'
      end
    end
  end
end
