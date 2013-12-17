Rivet CHANGELOG
===

1.5.0 - Released 12/17/13
---
  * BREAKING CHANGE: The gem list in bootstrap['gems'] must be converted from a list of
    Arrays to a Hash in yaml definition files, please look at README.md
  * BREAKING CHANGE: Now supports common yaml definitions in addition to group definitons
    Therefore, file structure has changed:
    ./autoscale/groups/<group name>
    ./autoscale/common/<config name>.yml | ./autoscale/common/<folder name>/<config name>.yml
  * The functionality to apply common configs is optional and done so in order of the 'include' array,
    as it first checks 'include' in the group_def to see if it is including any common_defs. If it is,
    it will deep merge defaults into the first common_def and then will deep merge subsquent common_defs,
    if any. Last, it will deep merge the result with the group_def and concat any arrays.
  * Improved Rivet's CLI option parser. It now uses OpenStruct instead of a Hash for the options,
    has cleaner user error messages with cmd help displayed and supports exit status codes

1.4.0 - Released 11/22/13
---
  * Adds functionality to apply an elastic_ip durning bootstrap
  * Adds functionality to apply knife commands for a specified chef_username durning bootstrap
  * Tweaked some of the code styling to adhere to common Ruby styling conventions:
    https://github.com/bbatsov/ruby-style-guide

1.3.0 - Released 11/20/13
---
  * Adds functionality to allow chef_command to be specified in group configurations

1.2.0 - Released 11/18/13
---
  * Adds functionality to apply tags to autoscaling groups
  * Updates Rivet to handle the new AWS CLI config file format (profiles now include the world profile in them)

1.1.0 - Released 11/12/13
---
  * Rivet no allows you to specify a directory with the -d [--definitions-directory] option
  * Rivet no longer creates the autoscale directory if it does not exist

1.0.8 - Released 11/12/13
---
  * Fixes the unit tests which were incorrect.

1.0.7 - Released 11/12/13
---
  * Fixes a bug where the run_list json was not rendered properly
  * Adds the iam_instance_profile option to the launch config.

1.0.6 - Released 11/11/2013
---
  * Fixes a bug when using sync and the launch configuration does not exist

1.0.5 - Released 11/11/2013
---
  * Removes an old unused function.  Adds additional logging to launch_config class

1.0.4 - Released 11/11/2013
---
  * Handles nil options in the launch_configuration gracefully.

1.0.3 - Released 11/11/2013
---
  * Updates the Gemfile.lock as I failed to do that after changing the Gemfile

1.0.2 - Released 11/11/2013
---
  * ACTUALLY changes the aws dependency since I apparently failed last time


1.0.1 - Released 11/11/2013
---
  * Changes aws-sdk dependency from 1.24.0 to >= 1.11.1 to avoid
    annoying nokogiri version lock in.

1.0.0 - Released 11/08/2013
---
  - Initial Release

