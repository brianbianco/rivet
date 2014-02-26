require_relative './spec_setup'

include SpecHelpers

describe "rivet aws autoscale wrapper" do
  let(:normalized_values) do
    {
      :launch_configuration => 'unit_test_lc',
      :load_balancers       => %w(balancer1 balancer2),
      :availability_zones   => %w(unit-test-1a unit-test-1b),
      :tags                 => [
        {:propagate_at_launch => true, :key => 'Name', :value => 'Unit Test'},
        {:propagate_at_launch => false, :key => 'Sandwich', :value => 'Ham'}
      ],
      :subnets              => %w(subnet-0000000a subnet-0000000b),
      :termination_policies => %w(policy1 policy2)
    }
  end

  let(:aws_mock) do
    subnet_mock1 = double('Aws EC2 subnet')
    subnet_mock1.stub(:id).and_return('subnet-0000000b')
    subnet_mock2 = double('Aws EC2 subnet')
    subnet_mock2.stub(:id).and_return('subnet-0000000a')

    mock = double('Aws Autoscaling Group')
    mock.stub(:health_check_type).and_return(:ec2)
    mock.stub(:desired_capacity).and_return(1)
    mock.stub(:max_size).and_return(2)
    mock.stub(:min_size).and_return(0)
    mock.stub(:launch_configuration_name).and_return('unit_test_lc')
    mock.stub(:load_balancer_names).and_return(%w(balancer2 balancer1))
    mock.stub(:availability_zone_names).and_return(%w(unit-test-1b unit-test-1a))
    mock.stub(:subnets).and_return([subnet_mock1, subnet_mock2])
    mock.stub(:termination_policies).and_return(%w(policy2 policy1))
    mock.stub(:default_cooldown).and_return(100)
    mock.stub(:health_check_grace_period).and_return(300)
    mock.stub(:placement_group).and_return('donkey')
    mock.stub(:name).and_return('unit_test_scaling_group')
    mock.stub(:tags).and_return([
      {:resource_id => 'snickers', :propagate_at_launch => true, :key => 'Name', :value => 'Unit Test'},
      {:resource_type => 'yogurt', :propagate_at_launch => false, :key => 'Sandwich', :value => 'Ham'}
    ])
    mock.stub(:exists?).and_return(true)
    mock
  end

  let(:groups_mock) do
    groups_mock = double('groups_mock')
    groups_mock.stub(:groups).and_return(group_mock)
    groups_mock
  end

  let(:group_mock) do
    group_mock = double('group_mock')
    group_mock.stub(:[]).with(/unit_test_scaling_group/).and_return(aws_mock)
    group_mock
  end

  let(:wrapper) { Rivet::AwsAutoscaleWrapper.new('unit_test_scaling_group') }

  before do
    AWS::AutoScaling.stub(:new).and_return(groups_mock)
  end

  describe "#normalize_launch_configuration" do
    it "returns launch configuration name" do
      wrapper.normalize_launch_configuration.should == 'unit_test_lc'
    end
  end

  describe "#normalize_load_balancers" do
    it "returns a normalized array of load balancers" do
      wrapper.normalize_load_balancers.should == %w(balancer1 balancer2)
    end
  end

  describe "#normalize_availability_zones" do
    it "returns a normalized array of availability zones" do
      wrapper.normalize_availability_zones.should == %w(unit-test-1a unit-test-1b)
    end
  end

  describe "#normalize_tags" do
    it "returns a normalized array of tags" do
      tags = [{:propagate_at_launch => true, :key => 'Name', :value => 'Unit Test'},
              {:propagate_at_launch => false, :key => 'Sandwich', :value => 'Ham'}]
      wrapper.normalize_tags.should == tags
    end
  end

  describe "#normalize_subnets" do
    it "returns a normalized array of subnets" do
      wrapper.normalize_subnets.should == %w(subnet-0000000a subnet-0000000b)
    end
  end

  describe "#normalize_termination_policies" do
    it "returns a normalized array of termination policies" do
      wrapper.normalize_termination_policies.should == %w(policy1 policy2)
    end
  end

  describe "#normalize_tag" do
    it "returns a normalized tag" do
      tag = {:resource_id => 'yoda', :resource_type => 'chewie',
             :propagate_at_launch => true, :key => 'place', :value => 'alderaan' }

      normalized_tag = { :propagate_at_launch => true, :key => 'place', :value => 'alderaan' }

      wrapper.send(:normalize_tag,tag).should == normalized_tag
    end
  end

  describe "#new" do
    it "should normalize values if normalize methods exist" do
      normalized_values.each_pair do |attr,value|
        wrapper.send(attr).should == value
      end
    end
  end
end
