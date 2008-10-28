set :application, "walnut"
set :repository,  "git@github.com:austintimeexchange/oscurrency.git"

default_run_options[:pty] = true
# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :user, "tbbrown"
set :use_sudo, false
set :deploy_to, "/home/tbbrown/public_html/#{application}.securityonrails.org"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm, "git"
#set :deploy_via, :remote_cache

ssh_options[:paranoid] = false;
ssh_options[:keys] = %w( /home/tbbrown/.ssh/id_rsa )

set :git_enable_submodules, 0
set :branch, "edge"

role :app, "#{application}.securityonrails.org"
role :web, "#{application}.securityonrails.org"
role :db,  "#{application}.securityonrails.org", :primary => true

set :mongrel_config, "/home/tbbrown/public_html/#{application}.securityonrails.org/current/config/mongrel_cluster.yml"
namespace :deploy do
  task :start do
    #nothing
  end
  task :restart do
    sudo "mongrel_rails cluster::restart -C #{mongrel_config}"
  end
end

task :after_update_code, :roles => :app,
  :except => {:no_symlink => true} do
  run <<-CMD
#    chmod 755 #{latest_release}/script/spin &&
    cd #{release_path} &&
    ln -nfs /home/tbbrown/public_html/#{application}.securityonrails.org/shared/config/database.yml #{release_path}/config/database.yml &&
    ln -nfs /home/tbbrown/public_html/#{application}.securityonrails.org/shared/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml &&
    ln -nfs /home/tbbrown/public_html/#{application}.securityonrails.org/shared/system/photos #{release_path}/public/photos &&
    ln -nfs /home/tbbrown/public_html/#{application}.securityonrails.org/shared/config/rsa_key #{release_path} &&
    ln -nfs /home/tbbrown/public_html/#{application}.securityonrails.org/shared/config/rsa_key.pub #{release_path}
  CMD
end
