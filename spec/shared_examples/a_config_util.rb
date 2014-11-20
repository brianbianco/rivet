# encoding: UTF-8

shared_examples 'a config util' do
  tempdir_context 'with an existing config directory' do

    before do
      FileUtils.mkdir_p config_dir
    end

    context 'without an existing configuration' do
      describe '#get_config' do
        it 'should return false' do
          Rivet::Utils.get_config('autoscale','unit_test', config_dir).should be_false
        end
      end
    end

    context 'with a configuration file' do
      before do
        File.open(config_file, 'w') { |f| f.write(config_content) }
      end

      describe '#get_config' do
        it 'should return a valid configuration' do
          config = Rivet::Utils.get_config('autoscale', 'unit_test', config_dir)
          valid_config?(config, dsl_values)
        end
      end
    end

  end
end

