module Rivet
  module Utils

    def self.die(level = 'fatal', message)
      Rivet::Log.write(level, message)
      exit 255
    end

    # This returns the merged definition given a group

    def self.get_definition(config, group, directory)
      defaults   = consume_defaults(directory)
      group_def  = load_definition(group, directory)
      config_def = load_definition(group, directory, config) if config

      # Deep merge group_def into the defaults or use group_def
      # NOTE: This will replace any arrays in default_def with group_def arrays
      definition = if defaults && group_def
        defaults.deep_merge(group_def)
      else
        group_def
      end

      # Now Deep merge the group's config_def into the definition using a block:
      # NOTE: This will concat any arrays in definition with config_def arrays and
      #       will remove duplicates (uniq), but user really should't be
      #       creating dups...
      definition = definition.deep_merge(config_def) do |k, tv, v|
        tv.is_a?(Array) ? tv.concat(v).uniq : v
      end if definition && config_def

      # Handle 'run_list' edge-case
      # NOTE: * It doesn't remove dups again, so don't create any (user responsiblity
      #         and yes it's possible by creating two runlist entries with differnt
      #         ordering positions.
      #       * config_def takes precedence on ordering position
      definition['bootstrap']['run_list'] = begin
        definition['bootstrap']['run_list'].inject([]) do |h, v|
          if v.respond_to? :each
            h.insert(v[1], v[0])
          else
            h << v
          end
        end
      end if definition && definition['bootstrap'] && definition['bootstrap']['run_list']

      definition ? definition : false
    end

    # Gobbles up the defaults file from YML, returns the hash or false if empty

    def self.consume_defaults(autoscale_dir)
      defaults_file = File.join(autoscale_dir, 'defaults.yml')
      if File.exists? defaults_file
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

    def self.load_definition(name, directory, config='conf.yml')
      definition_dir = File.join(directory, name)
      conf_file      = File.join(definition_dir, config)
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
