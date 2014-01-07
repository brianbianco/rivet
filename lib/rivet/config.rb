module Rivet
  class OpenState

    def install_get_or_set(name)
      define_singleton_method(name) do |*args|
        if args.size < 1
          instance_variable_get("@#{name}")
        else
          instance_variable_set("@#{name}",args[0])
        end
      end
    end

    def method_missing(m,*args,&block)
      if args.size < 1
        super
      else
        install_get_or_set(m)
        send(m,args[0])
      end
    end
  end

  class Config < OpenState
    attr_reader :name
    attr_accessor :bootstrap

    def self.from_file(path)
      name = File.basename(path,".rb")
      data = Proc.new { eval(File.read(path)) }
      new(name,&data)
    end

    def initialize(name,&block)
      @name = name
      @bootstrap = OpenState.new
      instance_eval(&block) if block
    end

    private

    def import(path)
      lambda { eval(File.read(path)) }.call
    end

  end
end
