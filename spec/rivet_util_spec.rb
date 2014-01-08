require_relative './rivet_spec_setup'

include SpecHelpers

AUTOSCALE_DIR           = '.'
AUTOSCALE_GROUPS_DIR    = File.join(AUTOSCALE_DIR, 'groups')
AUTOSCALE_COMMON_DIR    = File.join(AUTOSCALE_DIR, 'common')
GROUP_DEFINITION_NAME   = 'unit_test'
COMMON_DEFINITION_NAME  = 'unit_test_common'
DEFINITION_DIR          = File.join(AUTOSCALE_GROUPS_DIR, GROUP_DEFINITION_NAME)
LAUNCH_CONFIG_PARAMS    = %w(ssh_key instance_size security_groups ami bootstrap)

defaults_hash = {
  'min_size' => 0,
  'max_size' => 0,
  'region' => 'us-west-2',
  'zones' => %w(a b c),
  'key_name' => 'unit_tests',
  'instance_type' => 'm1.large',
  'security_groups' => %w(unit_tests),
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

unit_test_common_definition_hash = {
  'region' => 'us-east-1',
  'zones' => %w(a b c d)
}

describe "rivet utils" do
  tempdir_context "with an autoscaling directory" do
    before do
      FileUtils.mkdir_p AUTOSCALE_DIR
      FileUtils.mkdir_p AUTOSCALE_GROUPS_DIR
      FileUtils.mkdir_p AUTOSCALE_COMMON_DIR
    end

    describe "consume_defaults" do
      it "should return false" do
        Rivet::Utils.consume_defaults(AUTOSCALE_DIR).should be_false
      end
    end

    describe "load_definitions" do
      it "should return false" do
        Rivet::Utils.load_definition('unit_test', AUTOSCALE_GROUPS_DIR).should be_false
        Rivet::Utils.load_definition('unit_test_common', AUTOSCALE_COMMON_DIR).should be_false
      end
    end

    describe "get_definition" do
      it "should return false" do
        Rivet::Utils.get_definition('unit_test', AUTOSCALE_GROUPS_DIR)
      end
    end

    context "and with a group directory" do
      before do
        FileUtils.mkdir_p GROUP_DEFINITION_NAME
      end

      describe "load_definition" do
        it "should return false" do
          Rivet::Utils.load_definition('unit_test', AUTOSCALE_GROUPS_DIR).should be_false
        end
      end

      context "and with a conf.yml" do
        before do
          FileUtils.mkdir_p DEFINITION_DIR
          File.open(File.join(DEFINITION_DIR, 'conf.yml'), 'w') do |f|
            f.write(unit_test_definition_hash.to_yaml)
          end
        end
        describe "load_definition" do
          it "returns a hash" do
            loaded_def = Rivet::Utils.load_definition('unit_test', AUTOSCALE_GROUPS_DIR)
            unit_test_definition_hash.each_pair { |k,v| loaded_def.should include(k => v) }
          end
        end
        context "and with a defaults.yml" do
          before do
            File.open(File.join(AUTOSCALE_DIR, 'defaults.yml'), 'w') do |f|
              f.write(defaults_hash.to_yaml)
            end
          end

          describe "consume_defaults" do
            it "consume defaults returns a hash" do
              results = Rivet::Utils.consume_defaults(AUTOSCALE_DIR)
              defaults_hash.each_pair { |k,v| results.should include(k => v) }
            end
          end

          describe "get_definition" do
            it "returns a merged hash" do
             result = Rivet::Utils.get_definition(GROUP_DEFINITION_NAME, AUTOSCALE_DIR)
             merged_hash = defaults_hash.merge(unit_test_definition_hash)
             result.should == merged_hash
            end
          end
        end

        context "and with group using 'include' => 'unit_test_common'" do
          before do
            # Write new group conf.yml that uses 'include'
            File.open(File.join(DEFINITION_DIR, 'conf.yml'), 'w') do |f|
              f.write(unit_test_definition_hash.merge('include' => ['unit_test_common']).to_yaml)
            end
            # Make ./common dir and unit_test_common.yml
            FileUtils.mkdir_p AUTOSCALE_COMMON_DIR
            File.open(File.join(AUTOSCALE_COMMON_DIR, 'unit_test_common.yml'), 'w') do |f|
              f.write(unit_test_common_definition_hash.to_yaml)
            end
          end
          describe "load_definition" do
            it "returns a hash" do
              loaded_def = Rivet::Utils.load_definition('unit_test', AUTOSCALE_GROUPS_DIR)
              merged_hash = unit_test_definition_hash.merge('include' => ['unit_test_common'])
              merged_hash.each_pair { |k,v| loaded_def.should include(k => v) }
            end
          end
          describe "load_definition for common/unit_test_common.yml" do
            it "returns a hash" do
              loaded_def = Rivet::Utils.load_definition('common', AUTOSCALE_DIR, 'unit_test_common')
              unit_test_common_definition_hash.each_pair { |k,v| loaded_def.should include(k => v) }
            end
          end
          context "and with a defaults.yml" do
            before do
              File.open(File.join(AUTOSCALE_DIR, 'defaults.yml'), 'w') do |f|
                f.write(defaults_hash.to_yaml)
              end
            end

            describe "consume_defaults" do
              it "consume defaults returns a hash" do
                results = Rivet::Utils.consume_defaults(AUTOSCALE_DIR)
                defaults_hash.each_pair { |k,v| results.should include(k => v) }
              end
            end

            describe "get_definition" do
              it "returns a merged hash" do
               result = Rivet::Utils.get_definition(GROUP_DEFINITION_NAME, AUTOSCALE_DIR)
               merged_hash = defaults_hash.merge(unit_test_common_definition_hash).merge(unit_test_definition_hash)
               merged_hash.merge!('include' => ['unit_test_common'],
                                  'bootstrap' => {'run_list' => ["role[unit_tests]", "role[merging_test"]})
               result.should == merged_hash
              end
            end
          end
        end
      end

    end
  end
end
