# encoding: UTF-8

module Rivet
  class OpenState
    attr_reader :generated_attributes
    attr_accessor :required_fields

    def initialize
      @generated_attributes = []
    end

    def install_get_or_set(name)
      @generated_attributes << name
      define_singleton_method(name) do |*args|
        if args.size < 1
          instance_variable_get("@#{name}")
        else
          instance_variable_set("@#{name}", args[0])
        end
      end
    end

    def validate
      required_fields.each_pair do |method, default_value|
        unless respond_to?(method)
          if default_value.nil?
            raise "Required field #{method} missing!"
          else
            send(method, default_value)
          end
        end
      end
    end

    def method_missing(m, *args, &block)
      if args.size < 1
        super
      else
        install_get_or_set(m)
        send(m, args[0])
      end
    end
  end
end
