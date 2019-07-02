class ApplicationController < ActionController::Base
  before_action :load_all_playlists
  before_action :check_activeness

  def load_all_playlists
    if current_user
      @all_playlists = current_user.playlists.order('name ASC')
    end
  end

  def new_session_path(scope)
    new_user_session_path
  end

  def check_activeness
    if current_user and !current_user.active?
      sign_out_and_redirect(current_user)
    end
  end

end
