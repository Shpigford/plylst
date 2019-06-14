class PlaylistsController < ApplicationController
  def new
    @playlist = Playlist.new
  end

  def create
    @playlist = Playlist.new(playlist_params)
    @playlist.user = current_user

    if @playlist.save
      redirect_to edit_playlist_path(@playlist)
    else
      redirect_to new_playlist_path, alert: "Yeah, that didn't work."
    end
  end

  def show
    
  end

  def edit
    @playlist = Playlist.where(id: params[:id]).first
    
  end

  private
    def playlist_params
      params.require(:playlist).permit(:name)
    end
end
