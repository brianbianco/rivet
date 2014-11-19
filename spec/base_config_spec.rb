# encoding: UTF-8
require_relative './spec_setup'
require_relative './shared_examples/a_config'

include SpecHelpers

describe 'rivet base config' do
  let(:dsl_values) { COMMON_DSL_VALUES }
  let(:default_config) { Rivet::BaseConfig.new('default_unit_test_config') }
  let(:config) { Rivet::BaseConfig.new('unit_test_config') { eval(ASG_CONFIG_CONTENT) } }
  let(:config_from_file) { Rivet::BaseConfig.from_file(File.join('.', 'unit_test.rb')) }
  let(:config_content) { ASG_CONFIG_CONTENT }

  it_behaves_like "a config"

  context 'without DSL content' do
    describe '#new' do
      it 'returns a Rivet::BaseConfig object' do
        default_config.should be_an_instance_of Rivet::BaseConfig
      end
    end
  end

  context 'with DSL content' do
    describe '#new' do
      it 'returns a Rivet::BaseConfig object' do
        config.should be_an_instance_of Rivet::BaseConfig
      end
    end
  end
end
