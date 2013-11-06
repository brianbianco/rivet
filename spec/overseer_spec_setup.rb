require 'rspec'
require 'fileutils'
require 'tempfile'
require 'pathname'
require_relative '../lib/overseer'

Overseer::Log.level(Logger::FATAL)


module SpecHelpers

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
