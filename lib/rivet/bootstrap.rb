module Rivet
  class Bootstrap
    TEMPLATE_SUB_DIR = "bootstrap"

    attr_reader :gems, :run_list, :template, :environment
    attr_reader :template_path, :chef_command, :chef_organization

    def initialize(bootstrap_definition = Hash.new)
      ivars = [
        'gems','run_list','template','environment',
        'config_dir','chef_organization']

      ivars.each do |i|
        if bootstrap_definition.has_key?(i)
          instance_variable_set("@#{i}",bootstrap_definition[i])
        end
      end unless bootstrap_definition.nil?

      @config_dir ||= "."
      @template   ||= "default.erb"

      set_calculated_attrs
    end

    def user_data
      @user_data ||= generate_user_data
    end

    protected

    def set_calculated_attrs
      @template_path  = File.join(@config_dir,TEMPLATE_SUB_DIR)
      @chef_command   = "/usr/bin/chef-client -j /etc/chef/first-boot.json -L /root/first_run.log -E #{@environment}"
      @secret_file    = File.join(@config_dir,"encrypted_data_bag_secret_#{@environment}")
      @validation_key = File.new(File.join(@config_dir,"#{@chef_organization}-validator.pem")).read
    end

    def generate_user_data
      config_content = "log_level :info\n"
      config_content << "log_location STDOUT\n"
      config_content << "environment #{environment}\n"
      config_content << "chef_server_url  'https://api.opscode.com/organizations/#{chef_organization}'\n"
      config_content << "validation_client_name '#{chef_organization}-validator'\n"

      install_gems = String.new

      gems.each do |gem|
        if gem.size > 1
          install_gems << "gem install #{gem[0]} -v #{gem[1]} --no-rdoc --no-ri\n"
        else
          install_gems << "gem install #{gem[0]} --no-rdoc --no-ri\n"
        end
      end unless gems.nil?

      first_boot = { :run_list => @run_list.flatten }.to_json unless @run_list.nil?

      template = ERB.new File.new(File.join(@template_path,@template)).read
      template.result(binding)
    end

  end
end
