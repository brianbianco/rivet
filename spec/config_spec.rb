require_relative './spec_setup'

include SpecHelpers


describe 'rivet config' do
  let(:default_config) { Rivet::Config.new('default_unit_test_config') }
  let(:config) { Rivet::Config.new('unit_test_config') { eval(DSL_CONFIG_CONTENT) } }

  context 'without DSL content' do
    describe '#new' do
      it 'returns a Rivet::Config object' do
        default_config.should be_an_instance_of Rivet::Config
      end
    end

    describe '#name' do
      it 'returns the name' do
        default_config.name.should == 'default_unit_test_config'
      end
    end

    describe '#bootstrap' do
      before do
        default_config.bootstrap.unit_test 'goat simulator'
      end

      it 'should allow you to set an arbitrary bootstrap value' do
        default_config.bootstrap.unit_test.should == 'goat simulator'
      end
    end

    describe '#path' do
      context 'with no arguments' do
        it 'returns the default . path' do
          default_config.path.should == '.'
        end
      end
      context 'with an argument' do
        it 'returns the set path joined with the argument' do
          default_config.path('test').should == './test'
        end
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

    describe '#normalize_security_groups' do
      before do
        default_config.security_groups %w(group2 group1 group3)
      end

      it 'should return a sorted array of security groups' do
        default_config.normalize_security_groups.should == %w(group1 group2 group3)
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
          { propagate_at_launch: false, key: 'Other', value: 'sasquatch'}
        ]
        default_config.normalize_tags.should == expected_result
      end
    end
  end

  context 'with DSL content' do

    describe '#new' do
      it 'returns a Rivet::Config object' do
        config.should be_an_instance_of Rivet::Config
      end
    end

    describe '#name' do
      it 'returns the name' do
        config.name.should == 'unit_test_config'
      end
    end

    describe 'generated attributes' do
      it 'should contain all the attributes defined in the DSL CONTENT' do
        DSL_VALUES.each_pair do |k,v|
          # bootstrap is an attribute of the Config class, not a generated one
          unless k == :bootstrap
            config.generated_attributes.should include(k)
          end
        end
      end

      it 'should have all values properly set according to the DSL CONTENT' do
        DSL_VALUES.each_pair do |k,v|
          unless k == :bootstrap
            config.send(k).should == eval(v)
          end
        end
        DSL_VALUES[:bootstrap].each_pair do |k,v|
          config.bootstrap.send(k).should == eval(v)
        end
      end
    end
  end

  tempdir_context 'with DSL content inside of a file on disk' do
    let(:config_from_file) { Rivet::Config.from_file(File.join('.','unit_test.rb')) }

    before do
      File.open('unit_test.rb', 'w') { |f| f.write(DSL_CONFIG_CONTENT) }
    end

    describe '::from_file' do
      it 'returns an instance of Rivet::Config' do
        config_from_file.should be_an_instance_of Rivet::Config
      end

      it 'should have all values properly set according to the DSL CONTENT' do
        DSL_VALUES.each_pair do |k,v|
          unless k == :bootstrap
            config_from_file.send(k).should == eval(v)
          end
        end
        DSL_VALUES[:bootstrap].each_pair do |k,v|
          config_from_file.bootstrap.send(k).should == eval(v)
        end
      end
    end
  end

end
