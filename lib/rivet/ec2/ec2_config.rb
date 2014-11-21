#encoding: UTF-8

module Rivet
  class Ec2Config < BaseConfig

    def initialize(name, load_path='.', &block)
      @required_fields = {
        :image_id => nil,
        :region => 'us-east-1',
        :availability_zone => 'a'
      }
      super(name,load_path, &block)
    end

    def normalize_availability_zone
      region + availability_zone
    end
  end
end
