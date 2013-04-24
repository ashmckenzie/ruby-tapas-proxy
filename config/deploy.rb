require 'yaml'
require 'hashie'
require 'erb'
require 'capistrano-unicorn'

require 'bundler/setup'
Bundler.require(:default, :deploy)


deploy_file = File.expand_path('../deploy.yml', __FILE__)
app_file = File.expand_path('../config.yml', __FILE__)

DEPLOY_CONFIG = Hashie::Mash.new(YAML.load_file(deploy_file))
APP_CONFIG = Hashie::Mash.new(YAML.load_file(app_file))

set :bundle_cmd, '. /etc/profile && bundle'
require "bundler/capistrano"

set :application, "Ruby Tapas Proxy"
set :repository, DEPLOY_CONFIG.repo.url
set :branch, DEPLOY_CONFIG.repo.branch

set :scm, :git
set :scm_verbose, true

set :deploy_to, "#{DEPLOY_CONFIG.base}/#{DEPLOY_CONFIG.name}"
set :deploy_via, :remote_cache

set :keep_releases, 3
set :use_sudo, false
set :normalize_asset_timestamps, false

set :user, DEPLOY_CONFIG.ssh_user
ssh_options[:port] = DEPLOY_CONFIG.ssh_port
ssh_options[:keys] = eval(DEPLOY_CONFIG.ssh_key)
ssh_options[:forward_agent] = true

role :app, DEPLOY_CONFIG.ssh_host

after "deploy:update", "deploy:cleanup"
after "deploy:setup", "deploy:more_setup"

before "deploy:create_symlink",
  "deploy:configs",
  "nginx:config",
  "nginx:reload"

namespace :deploy do

  desc 'More setup.. ensure necessary directories exist, etc'
  task :more_setup do
    run "mkdir -p #{shared_path}/tmp/pids #{shared_path}/config #{shared_path}/config/unicorn"
  end

  desc 'Deploy necessary configs into shared/config'
  task :configs do
    put APP_CONFIG.to_yaml, "#{shared_path}/config/config.yml"
    run "ln -nfs #{shared_path}/config/config.yml #{release_path}/config/config.yml"
  end
end

namespace :nginx do

  desc 'Deploy nginx site configuration'
  task :config do
    config = DEPLOY_CONFIG.nginx

    nginx_base_dir = "/etc/nginx"
    nginx_available_dir = "#{nginx_base_dir}/sites-available"
    nginx_enabled_dir = "#{nginx_base_dir}/sites-enabled"
    nginx_available_file = "#{nginx_available_dir}/#{config.app_name}"

    put nginx_site_config(config), nginx_available_file
    run "ln -nsf #{nginx_available_file} #{nginx_enabled_dir}/"
  end

  desc 'Reload nginx'
  task :reload do
    sudo 'service nginx reload'
  end
end

namespace :unicorn do

  desc 'Deploy unicorn configuration'
  task :config do
    config = DEPLOY_CONFIG.unicorn
    config.working_directory = "#{current_release}"
    config.pid = "#{shared_path}/pids/unicorn.pid"
    config.stdout_log = "#{shared_path}/log/#{config.app_name}_stdout.log"
    config.stderr_log = "#{shared_path}/log/#{config.app_name}_stderr.log"

    unicorn_file = "#{shared_path}/config/unicorn/production.rb"

    put unicorn_config(config), unicorn_file
    run "ln -nfs #{shared_path}/config/unicorn/production.rb #{current_release}/config/unicorn/production.rb"
  end
end

def unicorn_config config
  template = ERB.new(File.read("config/unicorn.erb"))
  template.result(binding)
end

def nginx_site_config config
  template = ERB.new(File.read("config/nginx.erb"))
  template.result(binding)
end
