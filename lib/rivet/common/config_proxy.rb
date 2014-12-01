# encoding: UTF-8

module Rivet
  class ConfigProxy < BasicObject

    def initialize(config)
      @config = config
    end

    def send(m, *args)
      if @config.respond_to?("normalize_#{m}".to_sym)
        @config.send("normalize_#{m}".to_sym)
      else
        super
      end
    end

    def method_missing(m, *args, &block)
      if @config.respond_to?("normalize_#{m}".to_sym)
        @config.send("normalize_#{m}".to_sym)
      elsif @config.respond_to? m
        @config.send(m, *args, &block)
      else
        super
      end
    end
  end
end
