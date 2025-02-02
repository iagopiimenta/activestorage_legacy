require "active_storage/blob"
require "active_storage/patches/delegation"
require "strong_parameters" if Rails.version < '4.0'

# Attachments associate records with blobs. Usually that's a one record-many blobs relationship,
# but it is possible to associate many different records with the same blob. If you're doing that,
# you'll want to declare with `has_one/many_attached :thingy, dependent: false`, so that destroying
# any one record won't destroy the blob as well. (Then you'll need to do your own garbage collecting, though).
class ActiveStorage::Attachment < ActiveRecord::Base
  self.table_name = "active_storage_attachments"

  attr_protected if defined?(attr_protected)
  include ActiveModel::ForbiddenAttributesProtection if defined?(ActiveModel::ForbiddenAttributesProtection)

  belongs_to :record, polymorphic: true
  belongs_to :blob, class_name: "ActiveStorage::Blob"

  delegate_missing_to :blob

  # Purging an attachment will purge the blob (delete the file on the service, then destroy the record)
  # and then destroy the attachment itself.
  def purge
    blob.purge
    destroy
  end

  # Purging an attachment means purging the blob, which means talking to the service, which means
  # talking over the internet. Whenever you're doing that, it's a good idea to put that work in a job,
  # so it doesn't hold up other operations. That's what #purge_later provides.
  def purge_later
    ActiveStorage::PurgeAttachmentWorker.perform_async(self.id)
  end
end
