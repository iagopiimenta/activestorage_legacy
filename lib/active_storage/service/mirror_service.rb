require "active_storage/patches/delegation"

# Wraps a set of mirror services and provides a single `ActiveStorage::Service` object that will all
# have the files uploaded to them. A `primary` service is designated to answer calls to `download`, `exists?`,
# and `url`.
class ActiveStorage::Service::MirrorService < ActiveStorage::Service
  attr_reader :primary, :mirrors

  delegate :download, :exist?, :url, to: :primary

  # Stitch together from named services.
  def self.build(primary:, mirrors:, configurator:, **options) #:nodoc:
    new \
      primary: configurator.build(primary),
      mirrors: mirrors.collect { |name| configurator.build name }
  end

  def initialize(primary:, mirrors:)
    @primary, @mirrors = primary, mirrors
  end

  # Upload the `io` to the `key` specified to all services. If a `checksum` is provided, all services will
  # ensure a match when the upload has completed or raise an `ActiveStorage::IntegrityError`.
  def upload(key, io, checksum: nil)
    each_service.collect do |service|
      service.upload key, io.tap(&:rewind), checksum: checksum
    end
  end

  # Delete the file at the `key` on all services.
  def delete(key)
    perform_across_services :delete, key
  end

  private
    def each_service(&block)
      [ primary, *mirrors ].each(&block)
    end

    def perform_across_services(method, *args)
      # FIXME: Convert to be threaded
      each_service.collect do |service|
        service.public_send method, *args
      end
    end
end
