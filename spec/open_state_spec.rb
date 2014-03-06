# encoding: UTF-8
require_relative './spec_setup'

include SpecHelpers

describe 'Rivet OpenState' do
  let(:openstate) { Rivet::OpenState.new }

  describe '#install_get_or_set' do
    before do
      openstate.install_get_or_set(:tortilla)
    end

    it 'installs a getter' do
      openstate.should respond_to(:tortilla)
    end

    it 'installs a setter' do
      openstate.tortilla 'shells'
      openstate.tortilla.should == 'shells'
    end

    it 'adds the getter setter to generated attributes' do
      openstate.generated_attributes.should include(:tortilla)
    end
  end

  describe '#method_missing' do
    it 'adds an attribute when sent a message with an argument' do
      openstate.car %w(car horse tank)
      openstate.car.should == %w(car horse tank)
    end

    it 'raises an exception if sent a message that was not defined' do
      expect { openstate.sloth }.to raise_error
    end
  end

  describe '#validate' do
    before do
      openstate.required_fields = {
        :pickle => 'donkey',
        :donut  => nil,
        :cake   => 'chocolate'
      }
    end

    it 'raises an exception if a required attribute is not defined' do
      openstate.cake 'chocolate'
      openstate.pickle 'donkey'
      expect { openstate.validate }.to raise_error
    end

    it 'sets a default value if one is provided' do
      openstate.donut 'strawberry'
      openstate.validate
      openstate.pickle.should == 'donkey'
    end

    it 'returns true if all required fields have values' do
      openstate.cake 'chocolate'
      openstate.pickle 'donkey'
      openstate.donut 'strawberry'
      openstate.validate.should be_true
    end
  end
end
