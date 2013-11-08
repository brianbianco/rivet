require_relative './rivet_spec_setup'

include SpecHelpers

describe "rivet launch config" do
  let (:launch_config) { Rivet::LaunchConfig.new(SpecHelpers::AUTOSCALE_DEF) }

  context "with a valid autoscale definition" do
    before do
      user_data_mock = double('user_data_mock')
      user_data_mock.stub(:user_data).and_return("unit_test_user_data")
      Rivet::Bootstrap.stub(:new).and_return(user_data_mock)
    end

    describe "#build_identity_string" do
      it "should return a valid identity_string" do
        launch_config.send(:build_identity_string).should == SpecHelpers::AUTOSCALE_IDENTITY_STRING
      end
    end

    describe "#identity" do
      it "should return a deterministic identity" do
        launch_config.identity.should == "rivet_#{Digest::SHA1.hexdigest(SpecHelpers::AUTOSCALE_IDENTITY_STRING)}"
      end
    end

    describe "#normalize_security_groups" do
      it "returns a sorted array of groups" do
        unsorted_groups = ['group3','group1','group2']
        sorted_groups = unsorted_groups.sort
        returned_groups = launch_config.send(:normalize_security_groups,unsorted_groups)  
        returned_groups.should == sorted_groups
      end
    end
  end

end
