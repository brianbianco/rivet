import path('defaults.rb')
count 1
template path('user_data.erb')
availability_zone 'a'
tags [ { key: 'Name', value: 'example server' } ]

bootstrap.template path('user_data.erb')
bootstrap.packages ['ruby1.9.1', 'ruby1.9.1-dev', 'build-essential']

post do
  instances.each do |i|
    puts "instance id is #{i}"
  end
end
