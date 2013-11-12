require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'dotenv/capistrano'

# Application name
set :application, "S2"

# Repository
set :repository,  "git@github.com:huydx/S2.git"
set :scm, :git

# RVM
require 'rvm/capistrano'
set :rvm_ruby_string, 'ruby-1.9.3-p448'
set :rvm_type, :system
set :rvm_path, "/usr/local/rvm"

# Deploy user
set :user, 'deploy'
set :user_sudo, false
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

# Set tag, branch or revision
set :current_rev, `git show --format='%H' -s`.chomp
set :branch, "master"

set :unicorn_config,  "config/unicorn.rb"

# for Unicorn
namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && bundle exec unicorn_rails -c #{unicorn_config} -E #{rails_env} -D"
  end

  task :stop do
  end

  task :migrate, :roles => :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} rake db:migrate"
  end

  task :create_db, :roles => :db do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} rake db:create"
  end

  task :restart, :roles => :web, :except => { :no_release => true } do
    run "kill -USR2 `cat #{pid_file}`"
  end

  task :reload, :roles => :web, :except => { :no_release => true } do
    run "kill -HUP `cat #{pid_file}`"
  end

  task :delete_old do
    set :keep_releases, 2
  end
end
