#encoding: UTF-8

module Rivet
  class Ec2Config < BaseConfig

    def initialize(name, load_path='.', &block)
      @required_fields = {
        :image_id => nil
      }
      super(name,load_path, &block)
    end
  end
end
