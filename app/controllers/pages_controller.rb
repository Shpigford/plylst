class PagesController < ApplicationController
  def index
    if current_user
      @latest_streams = current_user.streams.limit(50)
    end
  end
  def home
    
  end
end
