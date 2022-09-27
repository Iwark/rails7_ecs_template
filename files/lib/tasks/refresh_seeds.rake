namespace :seeds do
  desc <<~LID
    Rewrite the seed file for the specified model with the current database contents.
    Usage:
      rake 'seeds:refresh[<model_name>]'
  LID
  task :refresh, %i[model_name] => :environment do |_task, args|
    model_name = args.model_name
    raise 'model_name is required' if model_name.blank?

    file_name = model_name.underscore.pluralize
    seed_file = Dir[Rails.root.join("db/seeds/**/*-#{file_name}.yml")].first
    raise 'seed file for the model is not found' if seed_file.nil?

    target_model = model_name.classify.constantize
    raise 'That model does not have any data' if target_model.all.blank?

    File.write(seed_file, JSON.parse(target_model.all.to_json).to_yaml)

    puts "Refreshed the seed data for #{seed_file}"
  end
end
