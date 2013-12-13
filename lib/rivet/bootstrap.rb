module Rivet
  class Bootstrap
    TEMPLATE_SUB_DIR = "bootstrap"

    attr_reader :gems, :run_list, :template, :environment, :region, :name, :elastic_ip
    attr_reader :template_path, :chef_command, :chef_organization, :chef_username

    def initialize(bootstrap_definition = {})
      ivars = [
        'gems', 'run_list', 'template', 'environment', 'region', 'name', 'elastic_ip',
        'config_dir', 'chef_command', 'chef_organization', 'chef_username']

      ivars.each do |i|
        if bootstrap_definition.has_key? i
          instance_variable_set("@#{i}", bootstrap_definition[i])
        end
      end unless bootstrap_definition.nil?

      @config_dir ||= '.'
      @template   ||= 'default.erb'

      set_calculated_attrs
    end

    def user_data
      @user_data ||= generate_user_data
    end

    protected

    def set_calculated_attrs
      @template_path  = File.join(@config_dir, TEMPLATE_SUB_DIR)
      @secret_file    = File.join(@config_dir, "encrypted_data_bag_secret_#{@environment}")
      @validation_key = File.new(File.join(@config_dir, "#{@chef_organization}-validator.pem")).read
    end

    def generate_user_data
      config_content =  "log_level :info\n"
      config_content << "log_location STDOUT\n"
      config_content << "environment '#{environment}'\n"
      config_content << "chef_server_url 'https://api.opscode.com/organizations/#{chef_organization}'\n"
      config_content << "validation_client_name '#{chef_organization}-validator'\n"

      knife_content =  "chef_username       = '#{chef_username}'\n"
      knife_content << "chef_organization   = '#{chef_organization}'\n"
      knife_content << "\n"
      knife_content << "environment         '#{environment}'\n"
      knife_content << "log_level           :info\n"
      knife_content << "log_location        STDOUT\n"
      knife_content << "node_name           \"\#{chef_username}\"\n"
      knife_content << "client_key          \"~/.chef/\#{chef_username}.pem\"\n"
      knife_content << "chef_server_url     \"https://api.opscode.com/organizations/\#{chef_organization}\"\n"
      knife_content << "cache_type          'BasicFile'\n"
      knife_content << "puts \"Using \#{environment} environment...\"\n"

      install_gems = ''

      gems.each do |k, v|
        if v
          install_gems << "gem install #{k} -v #{v} --no-rdoc --no-ri\n"
        else
          install_gems << "gem install #{k} --no-rdoc --no-ri\n"
        end
      end unless gems.nil?

      first_boot = { :run_list => @run_list.flatten }.to_json unless @run_list.nil?

      template = ERB.new File.new(File.join(@template_path, @template)).read
      template.result(binding)
    end

  end
end
