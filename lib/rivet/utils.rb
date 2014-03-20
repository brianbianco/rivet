# encoding: UTF-8

module Rivet
  module Utils
    def self.die(level = 'fatal', message)
      Rivet::Log.write(level, message)
      exit
    end

    def self.list_groups(directory)
      config_file_names = Dir.glob(File.join(directory,'*.rb'))
      config_file_names.map! {|f| File.basename(f,'.rb')}
      config_file_names.sort!
      Rivet::Log.info "Available groups in #{directory}:"
      config_file_names.each { |n| Rivet::Log.info n }
    end

    def self.get_config(name, directory)
      dsl_file = File.join(directory, "#{name}.rb")
      Rivet::Config.from_file(dsl_file, directory) if File.exists?(dsl_file)
    end
  end
end
