class ShortUrl < ApplicationRecord
  require 'open-uri'

  CHARACTERS = [*'0'..'9', *'a'..'z', *'A'..'Z'].freeze

  validate :validate_full_url

  def short_code #base62encode
    return nil if id.nil?
    p_id = id
    s = ''
    base = CHARACTERS.length
    while p_id > 0
      s << CHARACTERS[p_id.modulo(base)]
      p_id /= base
    end
    s.reverse
  end

  def update_title!
    begin
      title = open(full_url).read.scan(/<title>(.*?)<\/title>/).flatten
      self.update(title: title&.first)
    rescue OpenURI::HTTPError
      logger.error "Unable fetch the titlr URL: #{full_url}"
    end
  end

  private

  def validate_full_url
    return false unless full_url =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
    true
  end

  def logger
    @logger ||= Rails.logger
  end

end
