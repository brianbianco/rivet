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
          instance_variable_set("@#{name}",args[0])
        end
      end
    end

    def validate
      required_fields.each_pair do |method,default_value|
        unless respond_to?(method)
          if default_value.nil?
            raise "Required field #{method} missing!"
          else
            send(method,default_value)
          end
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
    attr_accessor :bootstrap,:required_fields

    def self.from_file(dsl_file,load_path='.')
      name = File.basename(dsl_file,".rb")
      data = Proc.new { eval(File.read(dsl_file)) }
      new(name,load_path,&data)
    end

    def initialize(name,load_path='.',&block)
      super()
      @name = name
      @path = load_path
      @bootstrap = OpenState.new
      @required_fields = {
        :min_size => nil,
        :max_size => nil,
        :availability_zones => nil,
        :default_cooldown => 300,
        :desired_capacity => 0,
        :health_check_grace_period => 0,
        :health_check_type => :ec2,
        :load_balancers => [],
        :subnets => [],
        :termination_policies => ["Default"]
      }
      instance_eval(&block) if block
    end

    def path(*args)
      if args.size < 1
        @path
      else
        File.join(@path,*args)
      end
    end

    protected

    def import(import_path)
      lambda { eval(File.read(import_path)) }.call
    end

  end
end
