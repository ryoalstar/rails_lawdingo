module Framey
  class VideosController < ApplicationController
    def index
    end

    def callback
      render text: "" and return unless request.post? && params[:video].present?

      video = Video.create!({
        name: params[:video][:name],
        filesize: params[:video][:filesize],
        duration: params[:video][:duration],
        state: params[:video][:state],
        views: params[:video][:views],
        flv_url: params[:video][:flv_url],
        mp4_url: params[:video][:mp4_url],
        small_thumbnail_url: params[:video][:small_thumbnail_url],
        large_thumbnail_url: params[:video][:large_thumbnail_url],
        creator_id: params[:video][:data][:creator_id]
      })

      render text: "" and return
    end
  end
end
