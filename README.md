[![Build Status](https://travis-ci.org/brianbianco/rivet.png)](https://travis-ci.org/brianbianco/rivet)

Rivet
=======
Rivet enables you to describe autoscaling groups, their launch configurations, and regular EC2 instances  as configuration.  You can then sync those changes to Amazon Web Services (AWS.)

You optionally provide a template and it's options to render as user-data for your launch configurations or EC2 instances. 

Rivet generates unique deterministic names for launch configurations and automatically assigns the proper launch configuration to your
autoscaling group based upon it's generated identity.


Installation
============

`gem install rivet`

Setup
=====

AWS Credentials
---------------

Rivet uses the python AWS CLI tools [https://github.com/aws/aws-cli] configuration format and file for it's AWS credentials.  This means it looks for a file located at AWS\_CONFIG\_FILE or ~/.aws/config if that is not set.

Right now Rivet only uses the following options from the file:

* `profile name`
* `aws_access_key_id`
* `aws_secret_access_key`
* `region`

An example config could look as follows:

```ini
[default]
aws_access_key_id=<YOUR ACCESS KEY ID>
aws_secret_access_key=<YOUR SECRET ACCESS KEY>
region=us-east-1

[foo]
aws_access_key_id=<YOUR ACCESS KEY ID>
aws_secret_access_key=<YOUR SECRET_ACCESS KEY>
region=us-west-2
```

Alternatively you can specify your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as environment variables.

You will still need to specify the region to use in your `AWS_CONFIG_FILE`.

Rivet will use the [default] profile if you do not specify a profile to use with the -p [--profile] option.


Definition directories and files
--------------------------------------------------

Example files can be found in the example/ directory in the rivet git repository

Rivet will look in the directory specified on the command line (./autoscale or ./ec2 by default) for configuration files.  It expects the configuration file name to match the name of the autoscaling group or EC2 instance. 

```
./autoscale
  `- name.rb
./ec2
  `- name.rb
```

Configuration DSL
-------------------------

You can execute any arbitrary ruby you please inside of a rivet configuration.

Rivets built in commands:

**path()**

- A function that returns the configuration directory path.
- optionally takes any number of strings as arguments and will return the configuration
  path with those strings joined to it.

**import(PATH)**

- A function that allows you to import other rivet configuration files

**bootstrap**

- provide this with a template file and a set of variables.  The variables will
be made available to the template file provided.  Rendered, and injected as EC2
user-data.

**post**

  provides a mechansim for you to pass a ruby block to be executed after a sync
  has completed.  Behavior is different for autoscale and ec2

  * EC2

  After instances have been successfully created block will be called.
  Instances method will be available inside the block and will contain an
  array of instance id's.

  ```
  post do
    instances.each do |x|
      puts x
    end
  end
  ```

  * Autoscale

  After the autoscaling group is synced the block will fire.  No information is
  currently passed in.
  ```
  post do
    puts "You gotta get schwifty in here"
  end
  ```

Rivet will only use the following attributes.

Autoscale Options
```
min_size INTEGER <required>
max_size INTEGER <required>
desired_capacity INTEGER <optional, default 0)
region STRING <required>
availability_zones ARRAY <required>
default_cooldown INTEGER <optional, default 300)
health_check_grace_period INTEGER <optional, default 0)
health_check_type SYMBOL <optional, default :ec2)
load_balancers ARRAY <optional, default nil)
subnet ARRAY <optional, default nil)
iam_instance_profile STRING <optional, default nil)
tags ARRAY <optional, default nil)
block_device_mapping ARRAY <optional, default nil>
```

EC2 Options
```
count INTEGER <required>
image_id STRING <required>
iam_instance_profile STRING <optional>
block_device_mapping ARRAY <optional>
monitoring_enabled BOOLEAN <optional>
availability_zone STRING <optional>
placement_group STRING <optional>
key_name STRING <optional>
security_groups ARRAY <optional>
security_group_ids ARRAY <optional>
instance_type STRING <optional>
kernel_id STRING <optional>
ramdisk_id STRING <optional>
disable_api_termination BOOLEAN <optional>
instance_initiated_shutdown_behavior STRING <optional>
subnet STRING <optional>
private_ip_address STRING <optional>
dedicated_tenancy BOOLEAN <optional>
ebs_optimized BOOLEAN <optional>
associate_public_ip_address BOOLEAN <optional>
elastic_ips ARRAY <optional>
network_interfaces ARRAY <optional>
```

Availability zones should use the single character of the zone ('a', 'b','c').  The region will be appended by rivet.

Tags should be an Array of Hashes with the format:
```
{  key: String,
   value: String,
   propogate_at_launch: True/False <optional, default True>'}
```
Block device mappings should be an array of Hashes with the format:
```
{
  virtual_name: String,
  device_name: String,
  ebs: {
    snapshot_id: String
    volume_size: Integer
    delete_on_termination: Boolean
    volume_type: String
    iops: Integer
  }
  no_device: String
}
```



Using the bootstrap functionality
---------------------------------

Rivet allows you to provide it with an ERB template as well as any number of variables to make
available to that template.  This will be rendered as user-data for the launch configuration.

The following attribute is required

bootstrap.template <some_path_to_a_template>

You may also provide any number of your own variables to use in the template

```
bootstrap.my_var "yellow"
bootstrap.number_of_elves 4
```

Rivet will pass a binding to the template such that you can access these options
without prepending bootstrap to them.

For example

`<%= my_var %>` in your template will render the string 'yellow'.

Usage
=====

```
Usage: rivet sub-command [options]
    sub-commands: ec2, autoscale

    -n, --name [NAME]                Server or Autoscaling group name
    -l, --log-level [LEVEL]          specify the log level (default is INFO)
    -p, --profile [PROFILE_NAME]     Selects the AWS profile to use (default is 'default')
    -s, --sync                       Sync the changes remotely to AWS
    -c, --config-path [PATH]         The autoscale config path to use (default is ./autoscale)
    -h
```

launch an ec2 instance

```bash
rivet ec2 -n example_instance
```

check the differences for the example_group autoscaling group

```bash
rivet autoscale -n example_group
```

check the differences for the example_group using the foobar profile

```bash
rivet autoscale -n example_group -p foobar
```

sync the differences for the example_group using the foobar profile

```bash
rivet autoscale -n example_group -p foobar -s
```

