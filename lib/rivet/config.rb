# encoding: UTF-8

module Rivet
  class Config < OpenState
    attr_reader :name
    attr_accessor :bootstrap

    def self.from_file(dsl_file,load_path='.')
      name = File.basename(dsl_file,'.rb')
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
        :tags => [],
        :termination_policies => ['Default']
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

    def normalize_availability_zones
      availability_zones.map { |zone| region + zone }.sort
    end

    def normalize_security_groups
      security_groups.sort
    end

    def normalize_load_balancers
      load_balancers.sort
    end

    def normalize_subnets
      subnets.sort
    end

    def normalize_tags
      normalized_tags = []
      tags.each do |t|
        normalized_hash = {}

        if t.has_key? :propagate_at_launch
          normalized_hash[:propagate_at_launch] = t[:propagate_at_launch]
        else
          normalized_hash[:propagate_at_launch] = true
        end

        [:value, :key].each do |k|
          if t.has_key? k
            normalized_hash[k] = t[k]
          else
            normalized_hash[k] = nil
          end
        end
        normalized_tags << normalized_hash
      end
      normalized_tags
    end

    protected

    def import(import_path)
      lambda { eval(File.read(import_path)) }.call
    end
  end
end
