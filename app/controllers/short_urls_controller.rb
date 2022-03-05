class ShortUrlsController < ApplicationController

  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token

  def index
    short_url_ids = ShortUrl.select(:id).order('click_count desc').limit(100)
    short_urls = short_url_ids.map(&:short_code)
    render status: 200, json: {urls: short_urls}
  end

  def create
    if (existing_entry = ShortUrl.find_by_full_url(params[:full_url]))
      render status: :created, json: existing_entry.short_code
    else
      short_url = ShortUrl.new(full_url: params[:full_url])
      if short_url.save
        render status: :created, json: { short_code: short_url.short_code }
      else
        render status: :unprocessable_entity, json: { errors: short_url.errors.full_messages }
      end
    end
  end

  def show
    short_code = params[:id]
    id = ShortUrl.decode(short_code)
    if id && (short_url = ShortUrl.find_by_id(id))
      short_url.increment!(:click_count)
      redirect_to(short_url.full_url)
    else
      render status: 404, json: { msg: 'URL Not Found in our records' }
    end
  end
end
