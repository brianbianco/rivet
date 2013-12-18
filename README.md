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

Rivet will look in the directory specified on the command line (or ./autoscale by default) for some definitions. It expects
a defaults.yml (optional) inside of it in whatever directory you use for your autoscaling definitions. Inside it, it expects
a 'groups' subdir where autoscale groups will have a directory named inside for them with a conf.yml. Using a group's defintion
attribute 'include', you may optionally include common defintion(s) from inside the 'common' subdir (./autoscale/common).
If you only want to include a single defintion, this can be a string. Otherwise, you'll need to make a list of strings
that point to the relative_filename_path, i.e. '<folder name>/<config name>(.yml)' or '<config name>(.yml)'. Adding the .yml extention is
optional when referencing the relative_filename_path, the filename itself must have the .yml extention though. It will first deep merge
in the defaults.yml (if any) and then deep merge in order of the array of 'include' for the common_defs (if any) and finally
with the group's definition coming last and taking precedence.

```
./autoscale
  `- defaults.yml
    `- common
      `- <config name>.yml
    `- groups
      `- <autoscale group name>
        `- conf.yml
```

defaults.yml, conf.yml and <config name>.yml all accept all the same options, except that conf.yml accepts an 'include' option to
include common defintion(s).  A group's definition will be deep merged over the defaults or results of the defaults and the
common definitons. Any arrays in the defaults or common defintions will be replaced by the subsquent defintion, except for the
group definition.  Instead, when at final deep merge of the group defintion, it will be concatenated (instead of replaced),
duplicates in arrays will be removed (please don't rely on this, keep your configs clean) and the bootstrap['run_list'] array
position ordering (if used) will take precedence, see below.

The yaml file format:

```yaml
include:
  - COMMON_DEFINITION_PATH <string>
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

In the above example, under bootstrap['run_list'], if ARRAY_POSITION for 'role[another_example_using_array_position' was 0,
it would come first, if ARRAY_POSITION was not used, it would come second as it respects the array's order by default.
Please try to design definitions files to take advanage of the fact that they are arrays and inherently have an
order whenever possible. In short, don't use this feature unless you really need it (keep configs SANE)!

Availability zones should use the single character of the zone.  The region will be appended by rivet.

The following files should exist in the configuration directory specified under the bootstrap -> config_dir key:

* A template file (specified by the bootstrap -> template file name)
* A validator pem (named by the bootstrap -> environment key as <environment>-validator.pem)


Usage
=====

```
Usage: rivet [options]
    -g, --group GROUP_NAME           Autoscaling group name
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
