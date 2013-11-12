require_relative './rivet_spec_setup'

include SpecHelpers

DEFINITION_NAME = "unit_test"
DEFINITION_DIR  = File.join(Rivet::Utils::AUTOSCALE_DIR,DEFINITION_NAME)
LAUNCH_CONFIG_PARAMS = ['ssh_key','instance_size','security_groups','ami','bootstrap']

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

describe "rivet utils" do
  tempdir_context "without an autoscaling directory" do
    describe "ensure_minimum_setup" do
      it "creates the autoscale directory if it doesn't exist" do
        Rivet::Utils.ensure_minimum_setup
        Dir.exists?(Rivet::Utils::AUTOSCALE_DIR).should be_true
      end
    end
  end

  tempdir_context "with an autoscaling directory" do
    before do
      FileUtils.mkdir_p(Rivet::Utils::AUTOSCALE_DIR)
    end

    describe "ensure_minimum_setup" do
      it "should return true" do
        Rivet::Utils.ensure_minimum_setup.should be_true
      end
    end

    describe "consume_defaults" do
      it "should return false" do
        Rivet::Utils.consume_defaults.should be_false
      end
    end

    describe "load_definition" do
      it "should return false" do
        Rivet::Utils.load_definition("unit_test").should be_false
      end
    end

    describe "get_definition" do
      it "should return false" do
        Rivet::Utils.get_definition("unit_test")
      end
    end

    context "and with a group directory" do
      before do
        FileUtils.mkdir_p DEFINITION_DIR
      end

      describe "load_definition" do
        it "should return false" do
          Rivet::Utils.load_definition("unit_test").should be_false
        end
      end

      context "and with a conf.yml" do
        before do
          FileUtils.mkdir_p DEFINITION_DIR
          File.open(File.join(DEFINITION_DIR,"conf.yml"),'w') do |f|
            f.write(unit_test_definition_hash.to_yaml)
          end
        end
        describe "load_definition" do
          it "returns a hash" do
            loaded_def = Rivet::Utils.load_definition("unit_test")
            unit_test_definition_hash.each_pair { |k,v| loaded_def.should include(k => v) }
          end
        end
        context "and with a defaults.yml" do
          before do
            File.open(File.join(Rivet::Utils::AUTOSCALE_DIR,"defaults.yml"),'w') do |f|
              f.write(defaults_hash.to_yaml)
            end
          end

          describe "consume_defaults" do
            it "consume defaults returns a hash" do
              results = Rivet::Utils.consume_defaults
              defaults_hash.each_pair { |k,v| results.should include(k => v) }
            end
          end

         describe "get_definition" do
           it "returns a merged hash" do
            result = Rivet::Utils.get_definition(DEFINITION_NAME)
            merged_hash = defaults_hash.merge(unit_test_definition_hash)
            result.should == defaults_hash.merge(unit_test_definition_hash)
           end
         end

        end

      end

    end
  end
end

