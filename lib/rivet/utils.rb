module Rivet
  module Utils
    AUTOSCALE_DIR = "autoscale"

    def self.die(level = 'fatal',message)
      Rivet::Log.write(level,message)
      exit
    end

    def self.ensure_minimum_setup
      if Dir.exists?(AUTOSCALE_DIR)
        true
      else
        Rivet::Log.info("Creating #{AUTOSCALE_DIR}")
        Dir.mkdir(AUTOSCALE_DIR)
      end
    end

    # This returns the merged definition given a group

    def self.get_definition(group)
      defaults = consume_defaults
      group_def = load_definition(group)
      if defaults && group_def
        group_def = defaults.deep_merge(group_def)
      end
    group_def ? group_def : false
    end

    # Gobbles up the defaults file from YML, returns the hash or false if empty

    def self.consume_defaults(autoscale_dir = AUTOSCALE_DIR)
      defaults_file = File.join(autoscale_dir,"defaults.yml")
      if File.exists?(defaults_file)
        parsed = begin
          Rivet::Log.debug("Consuming defaults from #{defaults_file}")
          YAML.load(File.open(defaults_file))
        rescue ArgumentError => e
          Rivet::Log.fatal("Could not parse YAML from #{defaults_file}: #{e.message}")
        end
        parsed
      else
        false
      end
    end

    # This loads the given definition from it's YML file, returns the hash or
    # false if empty

    def self.load_definition(name)
      definition_dir = File.join(AUTOSCALE_DIR,name)
      conf_file      = File.join(definition_dir,"conf.yml")
      if Dir.exists?(definition_dir) && File.exists?(conf_file)
        Rivet::Log.debug("Loading definition for #{name} from #{conf_file}")
        parsed = begin
          YAML.load(File.open(conf_file))
        rescue
          Rivet::Log.fatal("Could not parse YAML from #{conf_file}: #{e.message}")
        end
        parsed ? parsed : { }
      else
        false
      end
    end

  end
end

