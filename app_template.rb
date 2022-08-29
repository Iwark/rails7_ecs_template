def get_remote(src, dest = nil)
  dest ||= src
  repo = 'https://raw.github.com/Iwark/rails7_ecs_template/master/files/'
  remote_file = repo + src
  remove_file dest
  get(remote_file, dest)
end

@app_name = app_name

# vscode settings
run 'mkdir .vscode'
get_remote('vscode/settings.json', '.vscode/settings.json')

# .tool_versions
get_remote('tool-versions', '.tool-versions')

# gitignore
get_remote('gitignore', '.gitignore')

# CI/CD (github action)
run 'mkdir -p .github/workflows'
get_remote('github/workflows/deploy.yml', '.github/workflows/deploy.yml')
gsub_file ".github/workflows/deploy.yml", /myapp/, @app_name
get_remote('github/workflows/lint.yml', '.github/workflows/lint.yml')
get_remote('github/workflows/test.yml', '.github/workflows/test.yml')

# docker
get_remote('Dockerfile')
get_remote('docker-compose.yml')
get_remote('Procfile.dev')

# Set database config to use postgresql
get_remote('config/database.yml.example', 'config/database.yml')
run 'mkdir tmp/backups'

# assets
get_remote('app/assets/config/manifest.js')
get_remote('app/javascript/controllers/index.js')
get_remote('app/javascript/application.js')

# vendor
run 'mkdir vendor/javascript'
run 'touch vendor/javascript/.keep'

# components
run 'mkdir app/components'
get_remote('app/components/app_component.rb')

# tailwind
get_remote('config/tailwind.config.js')
get_remote('app/assets/stylesheets/application.tailwind.css')

#####
# Install gems
#####

get_remote('Gemfile')
run 'bundle lock --add-platform aarch64-linux-musl'
run 'bundle lock --add-platform x86_64-linux-musl'
run 'bundle install --path vendor/bundle --jobs=4'
run 'docker compose run web bundle install'

# install hotwire
run 'bundle exec rails hotwire:install'

# Fix pesky hangtime
run "spring stop"

# Simple Form
run 'bundle exec rails g simple_form:install'

# Devise
run 'bundle exec rails g devise:install'
get_remote('config/locales/devise.en.yml')
get_remote('config/locales/devise.ja.yml')
gsub_file "config/initializers/devise.rb", /'please-change-me-at-config-initializers-devise@example.com'/, '"no-reply@#{Settings.domain}"'

# set up db
run 'docker compose run web bundle exec rails db:create'

# annotate gem
run 'bundle exec rails g annotate:install'

# set config/application.rb
application  do
  %q{
    # Set timezone
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    
    # i18n default to japanese
    I18n.available_locales = [:en, :ja]
    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja
    
    # generator settings
    config.generators do |g|
      g.orm :active_record
      g.template_engine :slim
      g.test_framework  :rspec, :fixture => true
      g.view_specs false
      g.controller_specs false
      g.routing_specs false
      g.helper_specs false
      g.request_specs false
      g.assets false
      g.helper false
    end

    # load lib files
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # use sidekiq as active_job.queue_adapter
    config.active_job.queue_adapter = :sidekiq

    initializer "app_assets", after: "importmap.assets" do
      Rails.application.config.assets.paths << Rails.root.join('app') # for component sidecar js
    end

    # Sweep importmap cache for components
    config.importmap.cache_sweepers << Rails.root.join('app/components')
  }
end

# For Bullet (N+1 Problem)
insert_into_file 'config/environments/development.rb',%(

  # Config for bullet
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true # JavaScript alerts
    Bullet.bullet_logger = true # outputs to log/bullet.log
    Bullet.console = true # log to web console
    Bullet.rails_logger = true # log to rails log
  end

  config.hosts << Settings.domain
  config.web_console.permissions = '0.0.0.0/0'
), after: 'config.assets.quiet = true'

# Default url options for test
insert_into_file 'config/environments/test.rb',%(
  routes.default_url_options[:host]= 'localhost:3000'
), after: 'config.action_view.cache_template_loading = true'
gsub_file "config/environments/test.rb", 'config.eager_load = false', 'config.eager_load = ENV["CI"].present?'

# Letter opener
insert_into_file 'config/environments/development.rb',%(
  
  config.action_mailer.default_url_options = { host: Settings.domain, port: 3000 }
  config.action_mailer.delivery_method = :letter_opener_web
), after: 'config.action_mailer.perform_caching = false'

# SES
insert_into_file 'config/environments/production.rb',%(
  config.action_mailer.default_url_options = {
    protocol: 'https',
    host: Settings.domain,
  }
  config.action_mailer.delivery_method = :ses
), after: 'config.action_mailer.perform_caching = false'
gsub_file "config/environments/production.rb", 'config.active_storage.service = :local', 'config.active_storage.service = :amazon'

# Japanese locale
run 'wget https://raw.githubusercontent.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml -P config/locales/'

# erb to slim
run 'bundle exec erb2slim -d app/views'

# irbrc
get_remote('irbrc', '.irbrc')

# Rubocop
get_remote('rubocop.yml', '.rubocop.yml')

# Kaminari config
run 'bundle exec rails g kaminari:config'

# Rspec
run 'bundle exec rails g rspec:install'
run "echo '--color -f d' > .rspec"
get_remote('spec/rails_helper.rb')

# Lookbook
insert_into_file 'config/routes.rb',%(
  mount Lookbook::Engine, at: "/lookbook" unless Rails.env.production?
), after: 'Rails.application.routes.draw do'

# Guard
get_remote('Guardfile')

# Settings
run 'mkdir config/settings'
get_remote('config/settings/development.yml.example', 'config/settings/development.yml')
get_remote('config/settings/production.yml.example', 'config/settings/production.yml')
get_remote('config/settings/test.yml.example', 'config/settings/test.yml')
get_remote('config/settings.yml.example', 'config/settings.yml')
gsub_file "config/settings/development.yml", /myapp/, @app_name
gsub_file "config/settings/production.yml", /myapp/, @app_name
gsub_file "config/settings/test.yml", /myapp/, @app_name
gsub_file "config/settings.yml", /myapp/, @app_name

# AWS
get_remote('config/initializers/aws.rb')

# lograge
get_remote('config/initializers/lograge.rb')

# okcomputer
get_remote('config/initializers/okcomputer.rb')
get_remote('config/locales/okcomputer.en.yml')
get_remote('config/locales/okcomputer.ja.yml')

# switch_user
get_remote('config/initializers/switch_user.rb')

# sidekiq
get_remote('app/jobs/application_job.rb')
get_remote('config/initializers/sidekiq.rb')
get_remote('config/sidekiq.rb')

# sentry
get_remote('config/initializers/sentry.rb')

# sprockets
get_remote('config/initializers/web_app_manifest.rb')

# storage
get_remote('config/storage.rb')

# importmap
get_remote('config/importmap.rb')

# i18n-tasks
run 'cp $(bundle exec i18n-tasks gem-path)/templates/config/i18n-tasks.yml config/'
run 'cp $(bundle exec i18n-tasks gem-path)/templates/rspec/i18n_spec.rb spec/'

after_bundle do

  # rubocop
  run 'bundle exec rubocop -A'

  # git
  git :init
  git add: '.'
  git commit: "-a -m 'rails new #{@app_name} -m https://raw.githubusercontent.com/Iwark/rails7_ecs_template/master/app_template.rb'"
end