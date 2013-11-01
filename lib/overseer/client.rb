module Overseer
  class Client
    def initialize
    end

    def run(options)
      Overseer::Log.level(options[:log_level])
      Overseer.ensure_minimum_setup
      group_def = Overseer.get_definition(options[:group])
      autoscale_def = Overseer::Autoscale.new(options[:group],group_def)
      autoscale_def.show_differences
      autoscale_def.sync if options[:sync]
    end

  end
end

