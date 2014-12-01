# encoding: UTF-8
require_relative './spec_setup'
require_relative './shared_examples/a_config_util'

include SpecHelpers

describe "rivet utils" do
  context "with client_type set to autoscale" do

    let(:config_dir) { AUTOSCALE_DIR }
    let(:config_content) { ASG_CONFIG_CONTENT }
    let(:config_file) { ASG_CONFIG_FILE }
    let(:dsl_values) { ASG_DSL_VALUES }

    it_behaves_like "a config util"
  end

  context "with client_type set to ec2" do
    let(:config_dir) { EC2_DIR }
    let(:config_content) { EC2_CONFIG_CONTENT }
    let(:config_file) { EC2_CONFIG_FILE }
    let(:dsl_values) { EC2_DSL_VALUES }

    it_behaves_like "a config util"
  end

end
