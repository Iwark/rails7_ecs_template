def get_remote(src, dest = nil)
  dest ||= src
  repo = 'https://raw.github.com/Iwark/rails6_ecs_template/master/files/'
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
get_remote('github/workflows/build.yml', '.github/workflows/build.yml')
gsub_file ".github/workflows/build.yml", /myapp/, @app_name
get_remote('github/workflows/lint.yml', '.github/workflows/lint.yml')
get_remote('github/workflows/test.yml', '.github/workflows/test.yml')

# docker
get_remote('Dockerfile')
get_remote('docker-compose.yml')

# Set database config to use postgresql
get_remote('config/database.yml.example', 'config/database.yml')
run 'mkdir tmp/backups'

#####
# assets
#####

# fontawesome
run 'yarn add @fortawesome/fontawesome-free'
get_remote('app/javascript/packs/application.js')
get_remote('app/javascript/stylesheets/application.scss')
get_remote('app/assets/config/manifest.js')

# tailwind
run 'yarn add tailwindcss@latest postcss@latest postcss-loader@4.3 autoprefixer@latest'
get_remote('tailwind.config.js')

# alpinejs
run 'yarn add alpinejs alpine-turbo-drive-adapter'

# hotwire
run 'yarn remove turbolinks'
run 'yarn add @hotwired/turbo-rails stimulus'

run 'yarn'

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
  }
end

# For Bullet (N+1 Problem)
insert_into_file 'config/environments/development.rb',%(
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true # JavaScript alerts
    Bullet.bullet_logger = true # outputs to log/bullet.log
    Bullet.console = true # log to web console
    Bullet.rails_logger = true # log to rails log
  end

  config.hosts << Settings.domain
  config.web_console.permissions = '0.0.0.0/0'
), after: 'config.assets.debug = true'

# Default url options for test
insert_into_file 'config/environments/test.rb',%(
  routes.default_url_options[:host]= 'localhost:3000'
), after: 'config.action_view.cache_template_loading = true'

# SES
insert_into_file 'config/environments/production.rb',%(
  config.action_mailer.default_url_options = {
    protocol: 'https',
    host: Settings.domain,
  }
  config.action_mailer.delivery_method = :ses
), after: 'config.action_mailer.perform_caching = false'

# Japanese locale
run 'wget https://raw.githubusercontent.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml -P config/locales/'

# erb to slim
run 'bundle exec erb2slim -d app/views'
gsub_file 'app/views/layouts/application.html.slim', 'stylesheet_link_tag', 'stylesheet_pack_tag'
gsub_file 'app/views/layouts/application.html.slim', 'data-turbolinks-track', 'data-turbo-track'

# pryrc
get_remote('pryrc', '.pryrc')

# Rubocop
get_remote('rubocop.yml', '.rubocop.yml')

# Kaminari config
run 'bundle exec rails g kaminari:config'

# Rspec
run 'bundle exec rails g rspec:install'
run "echo '--color -f d' > .rspec"
get_remote('spec/rails_helper.rb')

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

# sidekiq
get_remote('app/jobs/application_job.rb')
get_remote('config/initializers/sidekiq.rb')

# sentry
get_remote('config/initializers/sentry.rb')

# i18n-tasks
run 'cp $(bundle exec i18n-tasks gem-path)/templates/config/i18n-tasks.yml config/'
run 'cp $(bundle exec i18n-tasks gem-path)/templates/rspec/i18n_spec.rb spec/'

after_bundle do

  # webpacker install
  run 'bundle exec rails webpacker:install'
  get_remote('postcss.config.js')
  get_remote('config/webpacker.yml')
  get_remote('config/webpack/environment.js')

  # rubocop
  run 'bundle exec rubocop -A'

  # git
  git :init
  git add: '.'
  git commit: "-a -m 'rails new #{@app_name} -m https://raw.githubusercontent.com/Iwark/rails6_ecs_template/master/app_template.rb'"
end