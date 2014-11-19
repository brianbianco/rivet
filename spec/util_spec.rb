# encoding: UTF-8
require_relative './spec_setup'

include SpecHelpers

describe 'rivet utils' do
  tempdir_context 'with an autoscale directory' do
    before do
      FileUtils.mkdir_p AUTOSCALE_DIR
    end

    context 'without an existing configuration' do
      describe '#get_config' do
        it 'should return false' do
          Rivet::Utils.get_autoscale_config('unit_test', AUTOSCALE_DIR).should be_false
        end
      end
    end

    context 'with a configuration file' do
      before do
        File.open(CONFIG_FILE, 'w') { |f| f.write(DSL_CONFIG_CONTENT) }
      end

      describe '#get_config' do
        it 'should return a valid configuration' do
          config = Rivet::Utils.get_autoscale_config('unit_test', AUTOSCALE_DIR)
          valid_config?(config, COMMON_DSL_VALUES)
        end
      end
    end

  end
end
