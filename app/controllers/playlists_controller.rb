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
    @playlist = Playlist.where(id: params[:id]).first

    @tracks = @playlist.filtered_tracks(current_user)
  end

  def edit
    @playlist = Playlist.where(id: params[:id]).first
  end

  def update
    @playlist = Playlist.where(id: params[:id]).first

    if @playlist.update_attributes(playlist_params)
      redirect_to playlist_path(@playlist)
    else
      render 'edit'
    end
  end

  private
    def playlist_params
      params.require(:playlist).permit(:name, :days_ago, :limit, :days_ago_filter, :bpm, :bpm_filter, :release_date_start, :release_date_end, :genres)
    end
end
