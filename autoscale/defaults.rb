region 'us-west-2'
availability_zones %w(a b c)
key_name 'ProdWest20130503'
instance_type 'm1.xlarge'
image_id 'ami-d3ce5ee3'

bootstrap.template path('default.erb')
bootstrap.chef_command '/usr/bin/chef-client -j /etc/chef/first-boot.json -L /root/first_run.log -E prodwest'
bootstrap.chef_organization 'cmwest'
bootstrap.chef_username 'ops_prodwest_cm'
bootstrap.environment 'prodwest'
bootstrap.region region
bootstrap.gems 'httparty' => '0.11.0',
               'net-ssh' => '2.2.2',
               'net-ssh-gateway' => '1.1.0',
               'net-ssh-multi' => '1.1',
               'json' => '1.7.6',
               'hipchat' => '0.12.0',
               'rake' => '10.0.4',
               'bundler' => '1.3.5',
               'aws-sdk' => '1.30.0',
               'ohai' => '6.20.0',
               'chef' => '11.8.0'
