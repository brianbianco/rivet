# encoding: UTF-8

module Rivet
  module Utils
    def self.die(level = 'fatal', message)
      Rivet::Log.write(level, message)
      exit
    end

    def self.get_config(name, directory)
      dsl_file = File.join(directory, "#{name}.rb")
      Rivet::Config.from_file(dsl_file, directory) if File.exists?(dsl_file)
    end
  end
end
