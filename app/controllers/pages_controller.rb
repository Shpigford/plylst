class PagesController < ApplicationController
  def index
    if current_user
      @latest_streams = current_user.streams.includes(:track, track: [:album, :artist]).limit(50).order('played_at DESC')
    end
  end

  def home
    
  end

  def genres
    @genres = Artist.pluck(:genres).reject!(&:empty?).flatten.group_by(&:itself).map { |k,v| [k, v.count] }.to_h.sort_by{|k,v| v}.reverse
  end
end
