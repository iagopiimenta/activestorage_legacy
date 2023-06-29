require 'sidekiq'

class ActiveStorage::PurgeBlobWorker
  include Sidekiq::Worker

  def perform(blob_id)
    ActiveStorage::Blob.where(id: blob_id).first&.purge
  end
end
