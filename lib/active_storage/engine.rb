require "rails/engine"

module ActiveStorage
  class Engine < Rails::Engine # :nodoc:
    config.active_storage = ActiveSupport::OrderedOptions.new

    # config.eager_load_namespaces << ActiveStorage

    initializer "active_storage.logger" do
      require "active_storage/service"

      config.after_initialize do |app|
        ActiveStorage::Service.logger = app.config.active_storage.logger || Rails.logger
      end
    end

    initializer 'active_storage.extend_active_record' do
      require "active_storage/patches"
      require "active_storage/patches/active_record"

      ActiveSupport.on_load :active_record do
        extend ActiveStorage::Patches::ActiveRecord
      end
    end

    initializer "active_storage.attached" do
      require "active_storage/attached"

      ActiveSupport.on_load(:active_record) do
        extend ActiveStorage::Attached::Macros
      end
    end

    # Port of Rails.application.key_generator.generate_key('ActiveStorage')
    #   Used to sign ActiveStorage::Blob
    # See: https://github.com/rails/activestorage/blob/archive/lib/active_storage/engine.rb#L27
    # https://github.com/rails/rails/blob/7-0-stable/activesupport/lib/active_support/key_generator.rb#L40
    initializer "active_storage.verifier" do
      require 'active_storage/verifier'

      config.after_initialize do |app|
        key = OpenSSL::PKCS5.pbkdf2_hmac(
          app.config.secret_token,
          'ActiveStorage',
          1000,
          64,
          OpenSSL::Digest::SHA256.new
        )
        ActiveStorage.verifier = ActiveStorage::Verifier.new(key)
      end
    end

    initializer "active_storage.services" do
      config.after_initialize do |app|
        if config_choice = app.config.active_storage.service
          config_file = Pathname.new(Rails.root.join("config/storage_services.yml"))
          raise("Couldn't find Active Storage configuration in #{config_file}") unless config_file.exist?

          require "yaml"
          require "erb"

          configs =
            begin
              YAML.load(ERB.new(config_file.read).result) || {}
            rescue Psych::SyntaxError => e
              raise "YAML syntax error occurred while parsing #{config_file}. " \
                    "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
                    "Error: #{e.message}"
            end

          ActiveStorage::Blob.service =
            begin
              ActiveStorage::Service.configure config_choice, configs
            rescue => e
              raise e, "Cannot load `Rails.config.active_storage.service`:\n#{e.message}", e.backtrace
            end
        end
      end
    end
  end
end
