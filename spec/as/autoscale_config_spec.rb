# encoding: UTF-8
require_relative '../spec_setup'
require_relative '../shared_examples/a_config'

include SpecHelpers

describe 'rivet autoscale config' do
  let(:dsl_values) { ASG_DSL_VALUES }
  let(:default_config) { Rivet::AutoscaleConfig.new('default_unit_test_config') }
  let(:config) { Rivet::AutoscaleConfig.new('unit_test_config') { eval(ASG_CONFIG_CONTENT) } }
  let(:config_from_file) { Rivet::AutoscaleConfig.from_file(File.join('.', 'unit_test.rb')) }
  let(:config_content) { ASG_CONFIG_CONTENT }

  it_behaves_like "a config"

  context 'without DSL content' do
    describe '#new' do
      it 'returns a Rivet::AutoscaleConfig object' do
        default_config.should be_an_instance_of Rivet::AutoscaleConfig
      end
    end

    describe '#normalize_availability_zones' do
      before do
        default_config.region 'us-west-2'
        default_config.availability_zones %w(c a b)
      end

      it 'should return a sorted array of zones with the region prepended' do
        default_config.normalize_availability_zones.should == %w(us-west-2a us-west-2b us-west-2c)
      end
    end

    describe '#normalize_load_balancers' do
      before do
        default_config.load_balancers %w(balancer2 balancer1)
      end

      it 'should return a sorted array of load balancers' do
        default_config.normalize_load_balancers.should == %w(balancer1 balancer2)
      end
    end

    describe '#normalize_subnets' do
      before do
        default_config.subnets %w(192.168.1.2 192.168.1.3 192.168.1.1)
      end

      it 'should return a sorted array of subnets' do
        default_config.normalize_subnets.should == %w(192.168.1.1 192.168.1.2 192.168.1.3) 
      end
    end

    describe '#normalize_tags' do
      before do
        default_config.tags [
          { key: 'Name', value: 'unit test' },
          { key: 'Other', value: 'sasquatch', propagate_at_launch: false }
        ]
      end

      it 'should return a normalized array of hashes' do
        expected_result = [
          { propagate_at_launch: true, key: 'Name', value: 'unit test' },
          { propagate_at_launch: false, key: 'Other', value: 'sasquatch' }
        ]
        default_config.normalize_tags.should == expected_result
      end
    end
  end

  context 'with DSL content' do
    describe '#new' do
      it 'returns a Rivet::AutoscaleConfig object' do
        config.should be_an_instance_of Rivet::AutoscaleConfig
      end
    end
  end

  tempdir_context 'with DSL content inside of a file on disk' do
    let(:config_from_file) { Rivet::AutoscaleConfig.from_file(File.join('.', 'unit_test.rb')) }

    before do
      File.open('unit_test.rb', 'w') { |f| f.write(ASG_CONFIG_CONTENT) }
    end

    describe '::from_file' do
      it 'returns an instance of Rivet::AutoscaleConfig' do
        config_from_file.should be_an_instance_of Rivet::AutoscaleConfig
      end
    end
  end
end
