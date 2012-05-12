require "bundler/capistrano"

server "106.187.93.47", :web, :app, :db, primary: true
set :user, "deployer"

set :application, "armory_recorder"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :repository,  "git@github.com:weih/armory-recorder.git"
set :scm, "git"
set :branch, "master"


default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :rvm_type, :user

namespace :deploy do
  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
  end
  after "deploy:setup", "deploy:setup_config"
end


set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ruby-1.9.3-p194/bin:/usr/local/rvm/gems/ruby-1.9.3-p194@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p194/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
  'RUBY_VERSION' => 'ruby-1.9.3-p194',
  'GEM_HOME' => '/usr/local/rvm/gems/ruby-1.9.3-p194',
  'GEM_PATH' => '/usr/local/rvm/gems/ruby-1.9.3-p194:/usr/local/rvm/gems/ruby-1.9.3-p194@global'
}

