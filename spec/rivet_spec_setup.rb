require 'rspec'
require 'fileutils'
require 'tempfile'
require 'pathname'
require 'base64'
require_relative '../lib/rivet'

Rivet::Log.level(Logger::FATAL)


module SpecHelpers


   BOOTSTRAP_TEMPLATE = '<%= install_gems %>'\
                        '<%= config_content %>'\
                        '<%= first_boot %>'\
                        "\n"\
                        '<%= chef_command %>'


  AUTOSCALE_DEF = {
    'min_size' => 1,
    'max_size' => 3,
    'region'   => 'us-west-2',
    'availability_zones' => ['a','b','c'],
    'key_name' => 'UnitTests',
    'instance_type' => 'm1.large',
    'security_groups' => ['unit_tests1','unit_tests2'],
    'image_id' => 'ami-12345678',
    'bootstrap' => {
      'chef_organization' => 'unit_tests',
      'template' => 'default.erb',
      'config_dir' => 'unit_tests',
      'environment' => 'unit_tests',
      'gems' => [ ['gem1','0.0.1'],['gem2','0.0.2'] ],
      'run_list' => ['unit_tests']
    }
  }

  AUTOSCALE_IDENTITY_STRING = "key_name#{Base64.encode64(AUTOSCALE_DEF['key_name'])}"\
                              "image_id#{Base64.encode64(AUTOSCALE_DEF['image_id'])}"\
                              "instance_type#{Base64.encode64(AUTOSCALE_DEF['instance_type'])}"\
                              "security_groups#{Base64.encode64(AUTOSCALE_DEF['security_groups'].join("\t"))}"\
                              "bootstrap#{Base64.encode64('unit_test_user_data')}"\

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
end
