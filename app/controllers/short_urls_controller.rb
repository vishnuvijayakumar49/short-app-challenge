class ShortUrlsController < ApplicationController

  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token

  def index
    short_url_ids = ShortUrl.select(:id).order('click_count desc').limit(100)
    short_urls = short_url_ids.map{|id_obj| id_obj.short_code}
    render status: 200, json: {urls: short_urls}
  end

  def create
  end

  def show
    short_code = params[:id]
    id = decode(short_code)
    redirect_to(ShortUrl.find(id).full_url)
  end

  private

  def create_params
    params.permit!(:full_url)
  end

  def decode(short_code)
    i = 0
    base = ShortUrl::CHARACTERS.length
    short_code.each_char { |c| i = i * base + ShortUrl::CHARACTERS.index(c) }
    i
  end

end
