require_relative './overseer_spec_setup'

include SpecHelpers

describe 'overseer bootstrap' do
  let (:bootstrap) { Overseer::Bootstrap.new(SpecHelpers::AUTOSCALE_DEF['bootstrap']) }
  let (:bootstrap_def) { SpecHelpers::AUTOSCALE_DEF['bootstrap'] }

  tempdir_context 'with all necessary files in place' do
    before do

      template = '<%= install_gems %>'\
                 '<%= config_content %>'\
                 '<%= first_boot %>'\
                 "\n"\
                 '<%= chef_command %>'

      validator_file = File.join(
        bootstrap_def['config_dir'],
        "#{bootstrap_def['environment']}-validator.pem")

      template_dir = File.join(
        bootstrap_def['config_dir'],
        Overseer::Bootstrap::TEMPLATE_SUB_DIR)

      template_file = File.join(template_dir,bootstrap_def['template'])

      FileUtils.mkdir_p(bootstrap_def['config_dir'])
      FileUtils.mkdir_p(template_dir)
      File.open(template_file,'w') { |f| f.write(template) }
      FileUtils.touch(validator_file)
    end

    describe "#user_data" do
      it 'returns a string that contains the chef organization' do
        org = bootstrap_def['organization']
        bootstrap.user_data.should =~ /chef_server_url\s*.*#{org}.*/
      end

      it 'returns a string that contains the environment' do
        env = bootstrap_def['env']
        bootstrap.user_data.should =~ /environment\s*.*#{env}.*/
      end

      it 'returns a string that contains the run_list as json' do
        run_list = { :run_list => bootstrap_def['run_list'].join(",") }.to_json
        bootstrap.user_data.should =~ /#{run_list}/
      end

      it 'returns a string that contains each gem to install' do
        bootstrap_def['gems'].each do |g|
          if g.size > 1
            gem_regexp = /gem\s*install\s*#{g[0]}.*#{g[1]}/
          else
            gem_regexp = /gem\s*install\s*#{g[0]}/
          end
          bootstrap.user_data.should =~ gem_regexp
        end
      end

    end

  end

end









