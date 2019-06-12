class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token
  
  def spotify
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user
      auth = request.env["omniauth.auth"]
      spotify_user = RSpotify::User.new(auth).to_hash
      @user.update_attribute(:settings, spotify_user)
      
      #FollowSpotifyJob.perform_async(current_user.id)

      sign_in_and_redirect @user, :event => :authentication
      set_flash_message(:notice, :success, :kind => 'Spotify') if is_navigational_format?
    end
  end

end