class ApplicationController < ActionController::Base
  before_action :load_all_playlists

  def load_all_playlists
    if current_user
      @all_playlists = current_user.playlists.order('name ASC')
    end
  end

end
