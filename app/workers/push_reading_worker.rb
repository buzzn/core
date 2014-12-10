class PushReadingWorker
  include Sidekiq::Worker

  def perform()
    reading = Reading.last
    logger.warn "pushing readings_13"
    WebsocketRails[:readings_13].trigger 'new', reading
  end
end