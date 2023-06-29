secrets = YAML.load(ERB.new(File.read("#{Rails.root}/config/secrets.yml")).result)[Rails.env]

Dummy::Application.config.secret_token = secrets['secret_key_base']
