Rivet CHANGELOG
===

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

