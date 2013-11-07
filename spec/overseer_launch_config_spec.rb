require_relative './overseer_spec_setup'

include SpecHelpers


describe "overseer launch config" do
  let (:launch_config) { Overseer::LaunchConfig.new(SpecHelpers::AUTOSCALE_DEF) }

  context "with a valid autoscale definition" do
    before do
      user_data_mock = double('user_data_mock')
      user_data_mock.stub(:user_data).and_return("unit_test_user_data")
      Overseer::Bootstrap.stub(:new).and_return(user_data_mock)
    end

    describe "#identity" do
      it "should return a deterministic identity" do
        launch_config.identity.should == SpecHelpers::AUTOSCALE_DEF_IDENTITY 
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
