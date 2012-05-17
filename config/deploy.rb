require "bundler/capistrano"

set :whenever_command, "bundle exec whenever"
require 'whenever/capistrano'

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

after "deploy", "deploy:cleanup" # keep only the last 5 releases


namespace :deploy do  
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
  end
  after "deploy:setup", "deploy:setup_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"


  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

#  task :save_armory do
#    run "cp -r #{current_path}/public/zh #{shared_path}/"
#  end
#  before "deploy", "deploy:save_armory"

  task :link_armory do
    run "ln -s #{shared_path}/zh #{current_path}/public/zh"
  end
  after "deploy", "deploy:link_armory"
end


set :rvm_type, :user
set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ruby-1.9.3-p194/bin:/usr/local/rvm/gems/ruby-1.9.3-p194@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p194/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
  'RUBY_VERSION' => 'ruby-1.9.3-p194',
  'GEM_HOME' => '/usr/local/rvm/gems/ruby-1.9.3-p194',
  'GEM_PATH' => '/usr/local/rvm/gems/ruby-1.9.3-p194:/usr/local/rvm/gems/ruby-1.9.3-p194@global'
}

