Dir.glob("#{Rails.root}/db/seeds/*.yml").reverse_each do |yaml_filename|
  target_model = File.basename(yaml_filename.split('-').last,".yml").classify.constantize
  target_model.delete_all
end

Dir.glob("#{Rails.root}/db/seeds/*.yml").each do |yaml_filename|
  target_model = File.basename(yaml_filename.split('-').last,".yml").classify.constantize
  File.open(yaml_filename) do |load_target_yaml|
    records = YAML.unsafe_load(load_target_yaml)

    records.each do |record|
      target_model.create!(record)
    end
    pp "created #{records.length} #{target_model} records"
  end
end
