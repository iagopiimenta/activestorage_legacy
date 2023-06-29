require 'sidekiq'

class ActiveStorage::PurgeAttachmentWorker
  include Sidekiq::Worker

  def perform(attachment_id)
    ActiveStorage::Attachment.where(id: attachment_id).first&.purge
  end
end
