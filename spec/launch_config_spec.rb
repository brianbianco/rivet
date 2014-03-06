# encoding: UTF-8
require_relative './spec_setup'

include SpecHelpers

describe 'rivet launch config' do
  let (:config) { generate_config_mock(double('config_mock'), DSL_VALUES) }
  let (:launch_config) { Rivet::LaunchConfig.new(config) }

  context 'with a sane config' do
    before do
      user_data_mock = double('user_data_mock')
      user_data_mock.stub(:user_data).and_return('unit_test_user_data')
      Rivet::Bootstrap.stub(:new).and_return(user_data_mock)
    end

    describe '#build_identity_string' do
      it 'should return a valid identity_string' do
        launch_config.send(:build_identity_string).should == SpecHelpers::AUTOSCALE_IDENTITY_STRING
      end
    end

    describe '#identity' do
      it 'should return a deterministic identity' do
        launch_config.identity.should == "rivet_#{Digest::SHA1.hexdigest(SpecHelpers::AUTOSCALE_IDENTITY_STRING)}"
      end
    end
  end

end
