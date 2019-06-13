class PagesController < ApplicationController
  def index
    if current_user
      @latest_streams = current_user.streams
    end
  end
  def home
    
  end
end
