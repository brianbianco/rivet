# encoding: UTF-8
require_relative './spec_setup'

include SpecHelpers

describe 'rivet bootstrap' do
  let(:config) { generate_config_mock(double('config_mock'), ASG_DSL_VALUES) }
  let(:bootstrap) { Rivet::Bootstrap.new(config) }
  let(:blank_config) do
    blank_config_mock = double('blank_config_mock')
    blank_config_mock.stub(:bootstrap).and_return
    generate_config_mock(blank_config_mock, {})
  end
  let(:blank_bootstrap) { Rivet::Bootstrap.new(blank_config) }

  tempdir_context 'with all necessary files in place' do
    before do
      FileUtils.mkdir_p AUTOSCALE_DIR
      File.open(TEMPLATE_FILE, 'w') { |f| f.write(SpecHelpers::BOOTSTRAP_TEMPLATE) }
    end

    context 'with a tempate file specified' do
      describe '#user_data' do
        it 'returns a string of the rendered template' do
          bootstrap.user_data.should include('bar')
        end
      end
    end

    context 'without a template specified' do
      describe '#user_data' do
        it 'returns a blank string' do
          blank_bootstrap.user_data.should be_empty
        end
      end
    end
  end
end
