class TracksController < ApplicationController
  def destroy
    track = Track.find(params[:id])
    followed_track = current_user.follows.find_by(track: track)
    followed_track.update_attribute(:active, false) if followed_track.present?

    redirect_to playlist_path(params[:playlist_id]), notice: "Blocked that track for you!"
  end

  private
  def track_params
    params.require(:track).permit(:user, :active, :playlist)
  end
end
