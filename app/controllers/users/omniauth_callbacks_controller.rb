class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token
  
  def spotify
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user
      auth = request.env["omniauth.auth"]
      spotify_user = RSpotify::User.new(auth).to_hash
      @user.update_attributes(settings: spotify_user, active: true)
      
      sign_in_and_redirect @user, :event => :authentication

      ProcessAccountWorker.perform_async(@user.id)
    end
  end

end