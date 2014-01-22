min_size 0
max_size 0
desired_capacity 0
region 'us-east-2'
availability_zones %w(a b c)
key_name 'YourKeyName'
instance_type 'm1.large'
security_groups ['group1','group2']
image_id 'ami-1234567'
iam_instance_profile 'some_iam_profile'

bootstrap.chef_organization 'YourChefOrg'
bootstrap.chef_command '/usr/bin/chef-client -j /etc/chef/first-boot.json -L /root/first_run.log'
bootstrap.template 'default.erb'
bootstrap.environment 'ChefEnvironment'
bootstrap.gems [
  { rake: '10.0.4' }
  { ohai: '6.16.0' }
  { chef: '11.6.0' }
]
bootstrap.run_list [ 'role[some_chef_role]' ]

