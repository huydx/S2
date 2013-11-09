set :rails_env, 'production'
set :deploy_env, 'production'
# Directories
set :deploy_to, "/usr/local/rails_apps/S2"
set :current_path, "#{deploy_to}/current"
set :pid_file, "/tmp/unicorn_s2.pid"

server "133.242.167.91", :app, :web, :db, primary: true
