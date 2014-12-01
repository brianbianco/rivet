# encoding: UTF-8
require_relative '../spec_setup'
require_relative '../shared_examples/a_config'

include SpecHelpers

describe 'rivet ec2 config' do
  let(:dsl_values) { EC2_DSL_VALUES }
  let(:default_config) { Rivet::Ec2Config.new('default_unit_test_config') }
  let(:config) { Rivet::Ec2Config.new('unit_test_config') { eval(EC2_CONFIG_CONTENT) } }
  let(:config_from_file) { Rivet::Ec2Config.from_file(File.join('.', 'unit_test.rb')) }
  let(:config_content) { EC2_CONFIG_CONTENT }

  it_behaves_like "a config"

  context 'without DSL content' do
    describe '#normalize_availability_zone' do
      before do
        default_config.region 'us-west-2'
        default_config.availability_zone 'a'
      end

      it 'should return a valid availability zone string' do
        default_config.normalize_availability_zone.should == 'us-west-2a'
      end
    end
  end
end

