require 'rspec'
require 'tempfile'
require 'pathname'
require 'fileutils'
require_relative '../lib/overseer.rb'

definition_name = "unit_test"
definition_dir  = File.join(Overseer::Utils::AUTOSCALE_DIR,definition_name)
launch_config_params = ['ssh_key','instance_size','security_groups','ami','bootstrap']

defaults_hash = {
  'min_size' => 0,
  'max_size' => 0,
  'region' => 'us-west-2',
  'zones' => ['a','b','c'],
  'key_name' => 'unit_tests',
  'instance_type' => 'm1.large',
  'security_groups' => ['unit_tests'],
  'image_id' => 'ami-unit_tests',
  'bootstrap' => {
    'run_list' => ['role[unit_tests]']
  }
}

unit_test_definition_hash = {
  'min_size' => 1,
  'max_size' => 5,
  'bootstrap' => {
    'run_list' => ['role[merging_test']
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

describe "overseer utils" do
  tempdir_context "without an autoscaling directory" do
    describe "ensure_minimum_setup" do
      it "creates the autoscale directory if it doesn't exist" do
        Overseer::Utils.ensure_minimum_setup
        Dir.exists?(Overseer::Utils::AUTOSCALE_DIR).should be_true
      end
    end
  end

  tempdir_context "with an autoscaling directory" do
    before do
      FileUtils.mkdir_p(Overseer::Utils::AUTOSCALE_DIR)
    end

    describe "ensure_minimum_setup" do
      it "should return true" do
        Overseer::Utils.ensure_minimum_setup.should be_true
      end
    end

    describe "consume_defaults" do
      it "should return false" do
        Overseer::Utils.consume_defaults.should be_false
      end
    end

    describe "load_definition" do
      it "should return false" do
        Overseer::Utils.load_definition("unit_test").should be_false
      end
    end

    context "and with a group directory" do
      before do
        FileUtils.mkdir_p definition_dir
      end

      describe "load_definition" do
        it "should return false" do
          Overseer::Utils.load_definition("unit_test").should be_false
        end
      end

      context "and with a conf.yml" do
        before do
          FileUtils.mkdir_p definition_dir
          File.open(File.join(definition_dir,"conf.yml"),'w') do |f|
            f.write(unit_test_definition_hash.to_yaml)
          end
        end
        describe "load_definition" do
          it "returns a hash" do
            loaded_def = Overseer::Utils.load_definition("unit_test")
            unit_test_definition_hash.each_pair { |k,v| loaded_def.should include(k => v) }
          end
        end
        context "and with a defaults.yml" do
          before do
            File.open(File.join(Overseer::Utils::AUTOSCALE_DIR,"defaults.yml"),'w') do |f|
              f.write(defaults_hash.to_yaml)
            end
          end

          describe "consume_defaults" do
            it "consume defaults returns a hash" do
              results = Overseer::Utils.consume_defaults
              defaults_hash.each_pair { |k,v| results.should include(k => v) }
            end
          end

         describe "get_definition" do
           it "returns a merged hash" do
            result = Overseer::Utils.get_definition(definition_name)
            merged_hash = defaults_hash.merge(unit_test_definition_hash)
            result.should == defaults_hash.merge(unit_test_definition_hash)
           end
         end

        end

      end

    end
  end
end

