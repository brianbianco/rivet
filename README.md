[![Build Status](https://travis-ci.org/brianbianco/rivet.png)](https://travis-ci.org/brianbianco/rivet)

Rivet
=======
Rivet enables you to describe autoscaling groups and their launch configurations as yaml.  You can then sync those changes to Amazon Web Services (AWS.)

You provide a template and it's options to render as user-data for your launch configurations to build a bootstrap script for chef, installed via gems.

Rivet generates unique deterministic names for launch configurations and automatically assigns the proper launch configuration to your
autoscaling group based upon it's generated identity.


Installation
============

`gem install rivet`

Setup
=====

AWS Credentials
---------------

Rivet uses the python AWS CLI tools [https://github.com/aws/aws-cli] configuration format and file for it's AWS credentials.  This means it looks for a file located at AWS\_CONFIG\_FILE.

Right now Rivet only uses the following options from the file:

* `profile name`
* `aws_access_key_id`
* `aws_secret_access_key`
* `region`

An example config could look as follows:

```ini
[profile default]
aws_access_key_id=<YOUR ACCESS KEY ID>
aws_secret_access_key=<YOUR SECRET ACCESS KEY>
region=us-east-1

[profile foo]
aws_access_key_id=<YOUR ACCESS KEY ID>
aws_secret_access_key=<YOUR SECRET_ACCESS KEY>
region=us-west-2
```

Alternatively you can specify your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as environment variables.

You will still need to specify the region to use in your `AWS_CONFIG_FILE`.

Rivet will use the [default] profile if you do not specify a profile to use with the -p [--profile] option.


Autoscaling group definition directories and files
--------------------------------------------------

Example files can be found in the example/ directory in the rivet git repository

Rivet will look in the directory specified on the command line (or ./autoscale by default) for some definitions.  It expects autoscale groups to have a directory named for them
with a conf.yml inside of it as well as a defaults.yml in whatever directory you use for your autoscaling group definitions. Optionally, you may specify a group's config, which
will be used in addition to the group's conf.yml and will take precedence over the group's conf.yml. For example, a group could have node(s) or sets of node(s) that have unique
attributes that differ from the base group's conf.yml.  Further, it expects these config(s) to be inside the group directory where the conf.yml also exists; there is no limit
for the amount of configs within a group, but you may only choose one at runtime.

```
./autoscale
  `- defaults.yml
     `- <autoscale group name>
        `- conf.yml
        `- <config name>.yml
```

defaults.yml, conf.yml and <config name>.yml all accept all the same options.  A groups definition will be deep merged over the defaults. Any arrays will be replaced by the
group definition.  If specified, a config name definition will also be deep merged over the resulting definition from the previous deep merge, except arrays will be
concatenated (instead of replaced), duplicates in arrays will be removed (please don't rely on this, keep your configs clean) and the config name's
bootstrap['run_list'] array position ordering (if used) will take precedence, see below.

The yaml file format:

```yaml
min_size: SIZE <integer>
max_size: SIZE <integer>
region: AWS_REGION <string>
availability_zones: [ZONE<string>, ZONE...]
iam_instance_profile: INSTANCE_PROFILE <string>
tags:
  -
    key: KEY_NAME<string>
    value: KEY_VALUE<string>
  -
    key: KEY_NAME<string>
    value: KEY_VALUE<string>

bootstrap:
  chef_command: CHEF_COMMAND <string>
  chef_organization: CHEF_ORGANIZATION <string>
  chef_username: CHEF_USERNAME <string>
  template: TEMPLATE <string>
  config_dir: CONFIGURATION_FILES_DIR <string>
  environment: CHEF_ENVIRONMENT <string>
  region: AWS_REGION <string>
  name: NAME <string>
  elastic_ip: AWS_ELASTIC_IP <string>
  gems:
    GEM_NAME<string>: GEM_VERSION<string>
    GEM_NAME<string>: ~
  run_list:
    - 'role[example]' <string>
    - ['role[another_example_using_array_position]' <string>, ARRAY_POSITION <integer>]

```

In the above example, under bootstrap['run_list'], if ARRAY_POSITION for 'role[another_example_using_array_position' was 0, it would come first,
if ARRAY_POSITION was not used, it would come second as it respects the array's order by default. Please try to design definitions files to take advanage
of the fact that they are arrays and inherently have an order whenever possible. In short, don't use this feature unless you really need it (keep configs SANE)!

Availability zones should use the single character of the zone.  The region will be appended by rivet.

The following files should exist in the configuration directory specified under the bootstrap -> config_dir key:

* A template file (specified by the bootstrap -> template file name)
* A validator pem (named by the bootstrap -> environment key as <environment>-validator.pem)


Usage
=====

```
Usage: rivet [options]
    -g, --group GROUP_NAME           Autoscaling group name
    -c, --config [CONFIG_NAME]       Specify config name (exclude '.yml') within an autoscaling group (optional)
    -l, --log-level [LEVEL]          Specify the log level (default is INFO)
    -p, --profile [PROFILE_NAME]     Selects the AWS profile to use (default is 'default')
    -s, --sync                       Sync the changes remotely to AWS
    -d [PATH],                       The autoscale definitions directory to use (default is ./autoscale)
        --definitions-directory
    -h
```

check the differences for the example_group autoscaling group

```bash
rivet -g example_group
```

check the differences for the example_group using the foobar profile

```bash
rivet -g example_group -p foobar
```

sync the differences for the example_group using the foobar profile

```bash
rivet -g example_group -p foobar -s
```

