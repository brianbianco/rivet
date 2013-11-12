[![Build Status](https://travis-ci.org/brianbianco/rivet.png)](https://travis-ci.org/brianbianco/rivet)

Rivet
=======
Rivet is a small utility which allows you to describe an autoscaling groups and it's launch configurations as yaml.  You can then sync those changes to AWS.

Rivet allows you to provide a template and it's options which will be rendered as user-data for your launch configurations.  It is currently opinionated and assumes you are trying to build
a bootstrap script for chef installed via gems.  You can of course provide it with any template you desire, and in future releases this system will become more flexible and less opinionated.

Rivet is also opinionated about how it names launch configurations, as it generates unique deterministic names for them and automatically assigns the proper launch configuration to your
autoscaling group based upon it's generated identity.

Installation
============

gem install rivet

Setup
=====

AWS Credentials
---------------

Rivet uses the python AWS CLI tools [https://github.com/aws/aws-cli] configuration format and file for it's AWS credentials.  This means it looks for a file located at AWS\_CONFIG\_FILE.

Right now Rivet only uses the following options from the file:

* profile name
* aws\_access\_key\_id
* aws\_secret\_access\_key
* region

An example config could look as follows:

```
[default]
aws_access_key_id<YOUR ACCESS KEY ID>
aws_secret_access_key=<YOUR SECRET ACCESS KEY>
region=us-east-1

[foo]
aws_access_key_id=<YOUR ACCESS KEY ID>
aws_secret_access_key=<YOUR SECRET_ACCESS KEY>
region=us-west-2
```

Alternatively you can specify your AWS\_ACCESS\_KEY\_ID and AWS\_SECRET\_ACCESS\_KEY as environment variables. 

You will still need to specify the region to use in your AWS\_CONFIG\_FILE.

Rivet will use the [default] profile if you do not specify a profile to use with the -p [--profile] option.


Autoscaling group definition directories and files
--------------------------------------------------

Example files can be found in the example/ directory in the rivet git repository

Rivet will look in the directory specified on the command line (or ./autoscale by default) for some definitions.  It expects autoscale groups to have a directory named for them
with a conf.yml inside of it as well as a defaults.yml in whatever directory you use for your autoscaling group definitions.

```
./autoscale
      | - defaults.yml
      | - <autoscale group name>
                  | - conf.yml
```

defaults.yml and conf.yml both accept all the same options.  A groups definition will be deep merged over the defaults.

The yaml file format:

```
min_size: SIZE <integer>
max_size: SIZE <integer>
region: AWS REGION <STRING>
availability_zones: [ZONE<string>,ZONE...]
iam_instance_profile: INSTANCE_PROFILE <string>

bootstrap:
  chef_organization: CHEF_ORGANIZATION <string>
  template: TEMPLATE <string>
  config_dir: CONFIGURATION_FILES_DIR <string>
  environment: CHEF_ENVIRONMENT <string>
  gems:
    - [GEM_NAME<string>,GEM_VERSION<string>]
    - [GEM_NAME<string>]
  run_list:
    - 'role[example]' <string>

```

Availability zones should use the single character of the zone.  The region will be appended by rivet.

The following files should exist in the configuration directory specified under the bootstrap -> config_dir key:

A template file (specified by the bootstrap -> template file name)
A validator pem (named by the bootstrap -> environment key as <environment>-validator.pem)


Usage
=====

```
Usage: rivet [options]
    -g, --group [GROUP_NAME]         Autoscaling group name
    -l, --log-level [LEVEL]          specify the log level (default is INFO)
    -p, --profile [PROFILE_NAME]     Selects the AWS profile to use (default is 'default')
    -s, --sync                       Sync the changes remotely to AWS
    -d [PATH],                       The autoscale definitions directory to use (default is ./autoscale)
        --definitions-directory
    -h
```

Using rivet to check the differences for the example_group autoscaling group

```bash
rivet -g example_group
```

Using rivet to check the differences for the example_group using the foobar profile

```bash
rivet -g example_group -p foobar
```

Using rivet to sync the differences for the example_group using the foobar profile

```bash
rivet -g example_group -p foobar -s
```

