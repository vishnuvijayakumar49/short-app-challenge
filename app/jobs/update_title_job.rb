class UpdateTitleJob < ApplicationJob
  queue_as :default

  def perform(short_url_id)
    logger.info("Enqueued shorl_url #{short_url_id}")
    short_url = ShortUrl.find_by_id(short_url_id)
    short_url.update_title!
  end

  private

  def logger
    @logger ||= Rails.logger
  end
end
