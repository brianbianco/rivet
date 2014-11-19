# encoding: UTF-8
require 'rspec'
require 'fileutils'
require 'tempfile'
require 'pathname'
require 'base64'
require_relative '../lib/rivet'

Rivet::Log.level(Logger::FATAL)

module SpecHelpers
  AUTOSCALE_DIR      = File.join('.', 'autoscale')
  CONFIG_FILE        = File.join(AUTOSCALE_DIR, 'unit_test.rb')
  TEMPLATE_FILE      = File.join(AUTOSCALE_DIR, 'default.erb')
  BOOTSTRAP_TEMPLATE = '<%= "bar" %>'\

  COMMON_DSL_VALUES = {
    :iam_instance_profile                 => "'ec2_unit_test_profile'",
    :block_device_mappings                => "[{:device_name => '/dev/sda1', :virtual_name => 'ephemeral0'}]",
    :placement_group                      => "'unit test placement group'",
    :image_id                             => "'ami-12345678'",
    :key_name                             => "'UnitTests'",
    :security_groups                      => '%w(unit_test3 unit_tests1 unit_tests2)',
    :instance_type                        => "'m1.large'",
    :kernel_id                            => "'aki-12345678'",
    :ramdisk_id                           => "'ari-12345678'",
    :associate_public_ip_address          => 'false'
  }


  EC2_DSL_VALUES = {
    :count                                => '1',
    :monitoring_enabled                   => 'true',
    :availability_zone                    => "'a'",
    :placement_group                      => "'unit test placement group'",
    :key_pair                             => "''",
    :security_group_ids                   => '%w(sg-12345678 sg-01234567 sg-801234567)',
    :user_data                            => "'ec2 user data'",
    :disable_api_termination              => 'false',
    :instance_initiated_shutdown_behavior => "'Stop'",
    :subnet                               => "'subnet-4292a736'",
    :private_ip_address                   => "'10.129.64.2'",
    :dedicated_tenancy                    => 'false',
    :ebs_optimized                        => 'false',
  }.merge(COMMON_DSL_VALUES)

  ASG_DSL_VALUES = {
    :min_size                     => '1',
    :desired_capacity             => '1',
    :max_size                     => '3',
    :region                       => "'us-west-2'",
    :availability_zones           => '%w(b c a)',
    :default_cooldown             => '300',
    :health_check_type            => ':ec2',
    :termination_policies         => '%w(policy2 policy1)',
    :load_balancers               => '%w(balancer2 balancer1)',
    :health_check_grace_period    => '100',
    :detailed_instance_monitoring => 'true',
    :spot_price                   => "'0.01'",
    :bootstrap                    => {
      :template => "'#{TEMPLATE_FILE}'",
      :foo => "'bar'"
    }
  }.merge(COMMON_DSL_VALUES)

  DSL_CONFIG_CONTENT = ASG_DSL_VALUES.inject(String.new) do |a, (k, v)|
    if k == :bootstrap
      v.each_pair do |bootstrap_attr, bootstrap_value|
        a << "bootstrap.#{bootstrap_attr} #{bootstrap_value}\n"
      end
    else
      a << "#{k} #{v}\n"
    end
    a
  end

  AUTOSCALE_IDENTITY_STRING = "bootstrap#{Base64.encode64('unit_test_user_data')}"\
                              "detailed_instance_monitoring#{Base64.encode64(eval(ASG_DSL_VALUES[:detailed_instance_monitoring]).to_s)}"\
                              "spot_price#{Base64.encode64(eval(ASG_DSL_VALUES[:spot_price]))}" \
                              "iam_instance_profile#{Base64.encode64(eval(ASG_DSL_VALUES[:iam_instance_profile]))}"\
                              "block_device_mappings#{Base64.encode64(eval(ASG_DSL_VALUES[:block_device_mappings]).join("\t"))}"\
                              "image_id#{Base64.encode64(eval(ASG_DSL_VALUES[:image_id]))}"\
                              "key_name#{Base64.encode64(eval(ASG_DSL_VALUES[:key_name]))}"\
                              "security_groups#{Base64.encode64(eval(ASG_DSL_VALUES[:security_groups]).join("\t"))}"\
                              "instance_type#{Base64.encode64(eval(ASG_DSL_VALUES[:instance_type]))}"\
                              "kernel_id#{Base64.encode64(eval(ASG_DSL_VALUES[:kernel_id]))}"\
                              "ramdisk_id#{Base64.encode64(eval(ASG_DSL_VALUES[:ramdisk_id]))}"\
                              "associate_public_ip_address#{Base64.encode64(eval(ASG_DSL_VALUES[:associate_public_ip_address]).to_s)}"

  def tempdir_context(name, &block)
    context name do
      before do
        @origin_dir = Dir.pwd
        @temp_dir = ::Pathname.new(::File.expand_path(::Dir.mktmpdir))
        Dir.chdir @temp_dir
      end

      after do
        Dir.chdir @origin_dir
        FileUtils.remove_entry(@temp_dir)
      end

      instance_eval &block
    end
  end

  def generate_config_mock(mock, attrs)
    attrs.each_pair do |a, v|
      if v.respond_to? :each_pair
        sub_mock = generate_config_mock(double("#{a} mock"), v)
        mock.stub(a).and_return(sub_mock)
      else
        mock.stub(a).and_return(eval(v))
      end
    end
    mock
  end

  def valid_config?(config, dsl_values)
    dsl_values.each_pair do |k, v|
      if v.respond_to? :each_pair
        valid_config?(config.send(k), v)
      else
        config.send(k).should == eval(v)
      end
    end
  end
end
