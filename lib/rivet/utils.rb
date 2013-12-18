module Rivet
  module Utils

    def self.die(level = 'fatal', message)
      Rivet::Log.write(level, message)
      exit 255
    end

    # This returns the merged definition given a group

    def self.get_definition(group, directory)
      defaults   = consume_defaults(directory)
      group_def  = load_definition(group, File.join(directory, 'groups'))

      # A successful rivet run requires a group_def, if none, bail out...
      if group_def
        definition =  if group_def['include']
                        # group_def['include'] can be an array of strings or a string (if containing only one common_def)
                        # If group_def includes common_def(s), merge them (in order)
                        #   1) defaults (if any) deep merge with first common_def
                        #   2) If common_defs, deep merge merged_result with subsequent common_defs
                        #   3) After last common_def deep merge, deep merge result with group_def (takes precendence)
                        #      with :concat_array option
                        # If no common_defs
                        #   1) Deep merge group_def into defaults (if any)
                        result =  if group_def['include'].respond_to? :each
                                    group_def['include'].each_with_index.inject({}) do |h, (filename_path, index)|
                                      common_def  = load_definition('common', directory, filename_path)
                                      if index == 0
                                        defaults ? deep_merge(defaults, common_def) : common_def
                                      else
                                        deep_merge(h, common_def)
                                      end
                                    end
                                  else
                                    filename_path = group_def['include']
                                    common_def  = load_definition('common', directory, filename_path)

                                    defaults ? deep_merge(defaults, common_def) : common_def
                                  end
                        deep_merge(result, group_def, :concat_arrays)
                      else
                        defaults ? deep_merge(defaults, group_def) : group_def
                      end

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

        definition
      else
        false
      end
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
      config = config.dup << '.yml' unless config[-4..-1] == '.yml'
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

    # This helper method returns the result of a deep_merge that either
    # replaces arrays or concats arrays

    def self.deep_merge(hash, other_hash, type=:replace_arrays)
      if type == :replace_arrays
        # Deep merge other_hash into the hash
        # NOTE: This will replace any arrays in hash with other_hash arrays
        hash.deep_merge(other_hash)
      elsif type == :concat_arrays
        # Now Deep merge the other_hash into the hash using a block:
        # NOTE: This will concat any arrays in hash with other_hash arrays and
        #       will remove duplicates (uniq), but user really should't be
        #       creating dups...
        hash.deep_merge(other_hash) do |k, tv, v|
          tv.is_a?(Array) ? tv.concat(v).uniq : v
        end
      else
        Rivet::Utils.die("InvalidArgument for Utils.deep_merge: 'type' => #{type}")
      end
    end
  end
end
