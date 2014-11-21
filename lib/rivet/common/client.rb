# encoding: UTF-8

module Rivet
  class Client
    def run(client_type,options)
      AwsUtils.set_aws_credentials options.profile
      Rivet::Log.level options.log_level

      Rivet::Log.info "Using #{client_type} config path #{options.config_path}"

      unless Dir.exists?(options.config_path)
        Rivet::Utils.die 'The #{client_type} config path does not exist'
      end

      config = Rivet::Utils.get_config(
        client_type,
        options.name,
        options.config_path)

      unless config
        Rivet::Utils.list_groups(options.config_path)
        Rivet::Utils.die "The #{options.name} #{client_type} definition doesn't exist"
      end

      config.validate

      config = ConfigProxy.new(config)

      Rivet::Log.info "#{options.name} #{client_type} definition"

      asset = Rivet.const_get(client_type.capitalize).new(config)
      asset.display

      if options.sync
        asset.sync
      else
        Rivet::Log.info 'use the -s [--sync] flag to sync changes'
      end
    end
  end
end
