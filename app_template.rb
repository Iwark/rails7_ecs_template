require 'net/http'
require 'uri'
require 'json'

REPO = 'Iwark/rails7_ecs_template'.freeze

def get_github_directory_contents(path)
  url = if path.start_with?('/') 
          URI.parse("https://api.github.com#{path}")
        else
          URI.parse("https://api.github.com/repos/#{REPO}/contents/#{path}")
        end
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = (url.scheme == 'https')
  request = Net::HTTP::Get.new(url.request_uri)
  request['Accept'] = 'application/vnd.github.v3+json'
  response = http.request(request)
  case response.code
  when '200'
    JSON.parse(response.body)
  when '302', '301'
    new_location = response['location']
    puts "Redirect to: #{new_location}"
    get_github_directory_contents(URI.parse(new_location).path)
  else
    puts "Error url: #{url}, response: #{response.code}"
    []
  end
end

def fetch_dir(path, local_dir=nil)
  local_dir ||= path
  path = "files/#{path}" unless path.start_with?('files/')
  FileUtils.mkdir_p(local_dir)
  get_github_directory_contents(path).each do |file|
    # Check if it's a file or a directory
    if file['type'] == 'file'
      local_file_path = File.join(local_dir, file['name'])
      get(file['download_url'], local_file_path)
    elsif file['type'] == 'dir'
      new_path = File.join(local_dir, file['name'])
      fetch_dir(file['path'], new_path)
    end
  end
end

def fetch_file(remote_file, local_file = nil)
  local_file ||= remote_file
  remote_file = "files/#{remote_file}" unless remote_file.start_with?('files/')
  remote_path = "https://raw.githubusercontent.com/#{REPO}/main/#{remote_file}"
  remove_file(local_file)
  get(remote_path, local_file)
end

@app_name = app_name

fetch_dir('vscode/', '.vscode/')
fetch_file('tool-versions', '.tool-versions')
fetch_file('gitignore', '.gitignore')

# CI/CD (github action)
fetch_dir('github/', '.github/')
gsub_file ".github/workflows/deploy.yml", /myapp/, @app_name

# docker
fetch_file('Dockerfile')
fetch_file('compose.yaml')
fetch_file('Procfile.dev')

@db_port = ask("Port for dev Postgres server (default: 5433)") || '5433'
@redis_port = ask("Port for dev Redis server (default: 6380)") || '6380'
@web_dev_port = ask("Port for Web dev server (default: 3000)") || '3000'
@chrome_port = ask("Port for Chrome server (default: 3300)") || '3300'

gsub_file "compose.yaml", '$DB_PORT', @db_port
gsub_file "compose.yaml", '$REDIS_PORT', @redis_port
gsub_file "compose.yaml", '$WEB_DEV_PORT', @web_dev_port
gsub_file "compose.yaml", '$CHROME_PORT', @chrome_port

gsub_file "Procfile.dev", '$WEB_DEV_PORT', @web_dev_port

# Set database config to use postgresql
fetch_file('config/database.yml.example', 'config/database.yml')
run 'mkdir tmp/backups'

fetch_dir('app/components/')
fetch_dir('app/validators/')

# tailwind
fetch_file('config/tailwind.config.js')
fetch_file('app/assets/stylesheets/application.tailwind.css')
insert_into_file 'app/views/layouts/application.html.erb', %(
    <%= stylesheet_link_tag "tailwind", "inter-font", "data-turbo-track": "reload", media: "all" %>
), after: '<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>'

run 'mkdir app/assets/builds'
run 'touch app/assets/builds/.keep'

#####
# Install gems
#####

fetch_file('Gemfile')
run 'bundle lock --add-platform aarch64-linux-musl'
run 'bundle lock --add-platform arm64-darwin-23'
run 'bundle lock --add-platform x86_64-linux'
run 'bundle lock --add-platform x86_64-linux-musl'
run 'bundle install --path vendor/bundle --jobs=4'
run 'docker compose run --rm web bundle install'

# Fix pesky hangtime
run "bundle exec spring stop"

# Devise
run 'bundle exec rails g devise:install'
gsub_file "config/initializers/devise.rb", /'please-change-me-at-config-initializers-devise@example.com'/, "\"no-reply@\#{ENV.fetch('APP_DOMAIN', 'dev.localhost')}\""

# set up db
run 'docker compose run --rm web bundle exec rails db:create'

# annotate gem
run 'bundle exec rails g annotate:install'

# set config/application.rb
application  do
  %q{
    # Set timezone
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
    
    # i18n default to japanese
    I18n.available_locales = %i[en ja]
    I18n.enforce_available_locales = true
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ja
    
    # generator settings
    config.generators do |g|
      g.orm :active_record
      g.template_engine :erb
      g.test_framework  :rspec, fixture: true
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

    # load validators
    config.autoload_paths += Dir[Rails.root.join('app', 'validators', '*')]

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

  config.hosts << ENV.fetch('APP_DOMAIN', 'dev.localhost')
  config.web_console.permissions = '0.0.0.0/0'
), after: 'config.assets.quiet = true'

# Default url options for test
insert_into_file 'config/environments/test.rb', %(
  config.action_mailer.default_url_options = { host: ENV.fetch('APP_DOMAIN', 'dev.localhost'), port: #{@web_dev_port} }
), after: 'config.action_mailer.delivery_method = :test'
gsub_file "config/environments/test.rb", 'config.eager_load = false', 'config.eager_load = ENV["CI"].present?'

# Letter opener
insert_into_file 'config/environments/development.rb',%(
  
  config.action_mailer.default_url_options = { host: ENV.fetch('APP_DOMAIN', 'dev.localhost'), port: #{@web_dev_port} }
  config.action_mailer.delivery_method = :letter_opener_web
), after: 'config.action_mailer.perform_caching = false'

# SES
insert_into_file 'config/environments/production.rb',%(
  config.action_mailer.default_url_options = {
    protocol: 'https',
    host: ENV.fetch('APP_DOMAIN'),
  }
  config.action_mailer.delivery_method = :ses
), after: 'config.action_mailer.perform_caching = false'
gsub_file "config/environments/production.rb", 'config.active_storage.service = :local', 'config.active_storage.service = :amazon'
gsub_file "config/environments/production.rb", '# config.cache_store = :mem_cache_store', "config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }"

# irbrc
fetch_file('irbrc', '.irbrc')

# Rubocop
fetch_file('rubocop.yml', '.rubocop.yml')

# Kaminari config
run 'bundle exec rails g kaminari:config'

# Rspec
run 'bundle exec rails g rspec:install'
run "echo '--color -f d' > .rspec"
fetch_file('spec/rails_helper.rb')
fetch_file('spec/spec_helper.rb')
fetch_file('spec/system_helper.rb')
fetch_dir('spec/validators/')
fetch_dir('spec/system/support/')
fetch_dir('spec/support/')
gsub_file "spec/system/support/cuprite_setup.rb", '$CHROME_PORT', @chrome_port

remove_file 'test'

fetch_dir('config/locales/')
remove_file 'config/locales/en.yml'

# Lookbook
insert_into_file 'config/routes.rb',%(
  mount Lookbook::Engine, at: "/lookbook" unless Rails.env.production?
), after: 'Rails.application.routes.draw do'

# Guard
fetch_file('Guardfile')

# AWS
fetch_file('config/initializers/aws.rb')

# lograge
fetch_file('config/initializers/lograge.rb')

# okcomputer
fetch_file('config/initializers/okcomputer.rb')

# switch_user
fetch_file('config/initializers/switch_user.rb')

# sidekiq
fetch_file('app/jobs/application_job.rb')
fetch_file('config/initializers/sidekiq.rb')
fetch_file('config/sidekiq.rb')

# sentry
fetch_file('config/initializers/sentry.rb')

# sprockets
fetch_file('config/initializers/web_app_manifest.rb')

# i18n-tasks
fetch_file('config/i18n-tasks.yml')
run 'cp $(bundle exec i18n-tasks gem-path)/templates/rspec/i18n_spec.rb spec/'

# seeds
fetch_file('db/seeds.rb')
run 'mkdir db/seeds'
run 'touch db/seeds/.keep'
fetch_file('lib/tasks/refresh_seeds.rake')

after_bundle do

  # javascripts & importmap
  fetch_file('app/assets/config/manifest.js')
  fetch_file('app/javascript/controllers/index.js')
  fetch_file('app/javascript/application.js')

  fetch_file('config/importmap.rb')

  # storage
  fetch_file('config/puma.rb')
  fetch_file('config/storage.yml')

  # i18n spec
  fetch_file('spec/i18n_spec.rb')

  # rubocop
  run 'bundle exec rubocop -A'

  # git
  git :init
  git add: '.'
  git commit: "-a -m 'rails new #{@app_name} -m https://raw.githubusercontent.com/#{REPO}/main/app_template.rb'"
end