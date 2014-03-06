# encoding: UTF-8

module Rivet
  class Bootstrap
    attr_reader :config

    def initialize(config)
      @config = config.bootstrap
    end

    def user_data
      @user_data ||= generate_user_data
    end

    protected

    def generate_user_data
      if config.respond_to?(:template)
        Rivet::Log.debug "Rendering #{config.template}"
        template = ERB.new(File.read(config.template))
        template.result(config.instance_eval { binding })
      else
        Rivet::Log.debug "No template provided, Rendering empty user-data"
        ""
      end
    end
  end
end
