# encoding: UTF-8

shared_examples_for "a config" do
  context 'without DSL content' do
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

    describe '#normalize_security_groups' do
      before do
        default_config.security_groups %w(group2 group1 group3)
      end

      it 'should return a sorted array of security groups' do
        default_config.normalize_security_groups.should == %w(group1 group2 group3)
      end
    end
  end

  context 'with DSL content' do
    describe '#name' do
      it 'returns the name' do
        config.name.should == 'unit_test_config'
      end
    end

    describe 'generated attributes' do
      it 'should contain all the attributes defined in the DSL CONTENT' do
        DSL_VALUES.each_pair do |k, v|
          # bootstrap is an attribute of the BaseConfig class, not a generated one
          unless k == :bootstrap
            config.generated_attributes.should include(k)
          end
        end
      end

      it 'should have all values properly set according to the DSL CONTENT' do
        DSL_VALUES.each_pair do |k, v|
          unless k == :bootstrap
            config.send(k).should == eval(v)
          end
        end
        DSL_VALUES[:bootstrap].each_pair do |k, v|
          config.bootstrap.send(k).should == eval(v)
        end
      end
    end
  end

  tempdir_context 'with DSL content inside of a file on disk' do
    before do
      File.open('unit_test.rb', 'w') { |f| f.write(DSL_CONFIG_CONTENT) }
    end

    describe '::from_file' do
      it 'should have all values properly set according to the DSL CONTENT' do
        DSL_VALUES.each_pair do |k, v|
          unless k == :bootstrap
            config_from_file.send(k).should == eval(v)
          end
        end
        DSL_VALUES[:bootstrap].each_pair do |k, v|
          config_from_file.bootstrap.send(k).should == eval(v)
        end
      end
    end
  end
end

