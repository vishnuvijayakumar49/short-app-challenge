class ShortUrl < ApplicationRecord
  require 'open-uri'

  CHARACTERS = [*'0'..'9', *'a'..'z', *'A'..'Z'].freeze

  validate :validate_full_url
  after_create :push_to_title_update_job

  # base62encode
  def short_code
    return nil if id.blank?

    p_id = id
    s = ''
    base = CHARACTERS.length
    while p_id.positive?
      s << CHARACTERS[p_id.modulo(base)]
      p_id /= base
    end
    s.reverse
  end

  def update_title!
    title = open(full_url).read.scan(%r{<title>(.*?)</title>}).flatten
    update(title: title&.first)
  rescue OpenURI::HTTPError
    logger.error "Unable fetch the title. URL: #{full_url}, ID: #{id}"
  end

  def push_to_title_update_job
    UpdateTitleJob.perform_later(id)
  end

  def self.decode(short_code)
    p_key = 0
    base = CHARACTERS.length
    short_code.each_char { |c| p_key = p_key * base + CHARACTERS.index(c) }
    p_key
  end

  private

  def validate_full_url
    if full_url.blank?
      errors.add :full_url, "can't be blank"
    elsif full_url !~ %r{^(http|https)://[a-z0-9]+([\-.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(/.*)?$}ix
      errors.add :full_url, 'is not a valid url'
    end
  end

  def logger
    @logger ||= Rails.logger
  end
end
