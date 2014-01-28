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
        template = ERB.new(File.read(config.template))
        template.result(config.instance_eval { binding })
      else
        ""
      end
    end
  end
end
