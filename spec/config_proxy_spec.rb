require_relative './spec_setup'

include SpecHelpers

describe 'Rivet Config Proxy' do
  let(:config) do
    config_mock = double('config_mock')
    config_mock.stub(:normalize_unit_test).and_return('normalized ham sandwich')
    config_mock.stub(:unit_test).and_return('ham sandwich')
    config_mock.stub(:goat).and_return('bah')
    config_mock
  end

  let(:config_proxy) { Rivet::ConfigProxy.new(config) }

  describe '#send' do
    it 'it calls normalize for a method if it iss available' do
      config_proxy.send(:unit_test).should == 'normalized ham sandwich'
    end
    it 'it passes on a message sent to it if no normalize method exists' do
      config_proxy.send(:goat).should == 'bah'
    end
  end

  describe 'it calls normalize for a method if it is available' do
    it 'it calls normalize for a method if it is available' do
      config_proxy.unit_test.should == 'normalized ham sandwich'
    end
    it 'it passes on a message sent to it if no normalize method exists' do
      config_proxy.goat.should == 'bah'
    end
  end
end
