# encoding: UTF-8

module Rivet
  class AwsAutoscaleWrapper

    OPTIONS = [
      :availability_zones,
      :default_cooldown,
      :desired_capacity,
      :health_check_grace_period,
      :health_check_type,
      :launch_configuration,
      :load_balancers,
      :max_size,
      :min_size,
      :placement_group,
      :subnets,
      :tags,
      :termination_policies
    ].each { |a| attr_reader a }

    attr_reader :name

    def initialize(name)
      Rivet::Log.debug "Initializing AWS Autoscale Wrapper for #{name}"
      @name = name
      @group = AWS::AutoScaling.new.groups[@name]

      if @group.exists?
        OPTIONS.each do |o|
          normalize_method = "normalize_#{o}".to_sym
          if respond_to?(normalize_method)
            Rivet::Log.debug "Calling #{normalize_method} in AWS autoscale wrapper"
            value = send(normalize_method)
          else
            value = @group.send(o)
          end
          instance_variable_set("@#{o}", value)
        end
      end

    end

    def normalize_launch_configuration
      @group.launch_configuration_name
    end

    def normalize_load_balancers
      @group.load_balancer_names.to_a.sort
    end

    def normalize_availability_zones
      @group.availability_zone_names.to_a.sort
    end

    def normalize_tags
      @group.tags.to_a.inject([]) do |normalized_tags, current|
        normalized_tags << normalize_tag(current)
      end
    end

    def normalize_subnets
      @group.subnets.empty? ? nil : @group.subnets.map(&:id).sort
    end

    def normalize_termination_policies
      @group.termination_policies.to_a.sort
    end

    protected

    def normalize_tag(tag)
      normalized_tag = {}
      tag.each_pair do |k, v|
        unless (k == :resource_id || k == :resource_type)
          normalized_tag[k] = v
        end
      end
      normalized_tag
    end
  end
end
