require 'vendor/plugins/thinking-sphinx/recipes/thinking_sphinx'

set :application, "open-active-democracy"
set :domain, "p.vidraedur.is"
set :selected_branch, "esb"
set :repository, "git://github.com/rbjarnason/open-active-democracy.git"
set :use_sudo, false
set :deploy_to, "/home/robert/sites/#{application}/#{selected_branch}"
set :branch, "#{selected_branch}"
set :user, "robert"
set :deploy_via, :remote_cache

set :scm, "git"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

task :before_update_code, :roles => [:app] do
  thinking_sphinx.stop
end

task :after_update_code, :roles => [:app] do
  symlink_sphinx_indexes
  thinking_sphinx.configure
  thinking_sphinx.start
end

task :after_update_code do
  run "ln -nfs #{deploy_to}/#{shared_dir}/db/sphinx #{current_release}/db/sphinx"
  run "ln -s #{deploy_to}/#{shared_dir}/config/database.yml #{current_release}/config/database.yml"
  run "ln -s #{deploy_to}/#{shared_dir}/config/facebooker.yml #{current_release}/config/facebooker.yml"
  run "ln -s #{deploy_to}/#{shared_dir}/production #{current_release}/public/production"
  run "rm #{deploy_to}/#{shared_dir}/system/system"
  run "ln -s #{deploy_to}/#{shared_dir}/system #{current_release}/public/system"
  run "ln -s #{deploy_to}/#{shared_dir}/private #{current_release}/private"
  #run "rm -f #{current_path}"
end

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

deploy.task :start do
# nothing
end


Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
