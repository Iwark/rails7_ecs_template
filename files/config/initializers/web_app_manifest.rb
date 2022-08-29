# This file makes files with .webmanifest and .xml extensions first class files in the asset
# pipeline. This is to preserve this extensions, as is it referenced in a call
# to asset_path in the head tag.

Rails.application.config.assets.configure do |env|
  manifest_mime_type = 'application/manifest+json'
  manifest_extensions = ['.webmanifest']

  xml_mime_type = 'application/xml'
  xml_extensions = ['.xml']  

  if Sprockets::VERSION.to_i >= 4
    manifest_extensions << '.webmanifest.erb'    
    env.register_preprocessor(manifest_mime_type, Sprockets::ERBProcessor)

    xml_extensions << '.xml.erb'    
    env.register_preprocessor(xml_mime_type, Sprockets::ERBProcessor)
  end  
  
  env.register_mime_type(manifest_mime_type, extensions: manifest_extensions)
  env.register_mime_type(xml_mime_type, extensions: xml_extensions)
end
