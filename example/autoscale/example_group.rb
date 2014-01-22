import path('defaults.rb')

min_size 1
max_size 3
desired_capacity 2
region 'us-west-2'
tags [ { key: 'Name', value: 'Value' } ]

bootstrap.run_list [ 'role[example]' ]

