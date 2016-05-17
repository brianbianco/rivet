# encoding: UTF-8

module Rivet
  class BaseConfig < OpenState
    attr_reader :name
    attr_accessor :bootstrap

    def self.from_file(dsl_file, load_path='.')
      name = File.basename(dsl_file, '.rb')
      data = Proc.new { eval(File.read(dsl_file)) }
      new(name, load_path, &data)
    end

    def initialize(name, load_path='.', &block)
      super()
      @name = name
      @path = load_path
      @bootstrap = OpenState.new
      instance_eval(&block) if block
    end

    def path(*args)
      if args.size < 1
        @path
      else
        File.join(@path, *args)
      end
    end

    def post(&block)
      return @block if block.nil?
      @block = block
    end

    def normalize_security_groups
      security_groups.sort
    end

    protected

    def import(import_path)
      lambda { eval(File.read(import_path)) }.call
    end
  end
end
