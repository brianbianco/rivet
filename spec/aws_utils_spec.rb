# encoding: UTf-8
require_relative './spec_setup'

include SpecHelpers

describe 'rivet awsutils' do
  describe 'parse_profile_text' do
    let(:profile_hash) do
      {
        'unit_test_profile1' => {
          'option1' => 'unit_test_option1',
          'option2' => 'unit_test_option2'
        },
        'unit_test_profile2' => {
          'option1    ' => 'unit_test_option1',
          'option2' => 'unit_test_option2     '
        }
      }
    end

    let(:profile_text) do
      p = String.new
      profile_hash.each_pair do |profile,options|
        p << "[profile #{profile}]\n"
        options.each_pair { |name,value| p << "#{name.chomp} = #{value.chomp}\n" }
      end
      p
    end

    it 'should contain the profile as top level keys' do
      result = Rivet::AwsUtils.parse_profile_text(profile_text)
      profile_hash.each_pair { |profile,_| result.should have_key profile }
    end

    it 'should set all options properly inside the profile hash' do
      result = Rivet::AwsUtils.parse_profile_text(profile_text)
      profile_hash.each_pair do |profile,options|
        options.each_pair do |name, value|
          result[profile][name.strip.to_sym].should == value.strip
        end
      end
    end
  end
end
