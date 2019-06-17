class PlaylistsController < ApplicationController
  before_action :authenticate_user!

  def index
    @playlists = Playlist.where(:user_id => current_user.id)
  end
  
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
    @playlist = current_user.playlists.find(params[:id])

    @tracks = @playlist.filtered_tracks(current_user).includes(:album, :artist, :follows)
  end

  def edit
    @playlist = current_user.playlists.find(params[:id])
  end

  def update
    @playlist = current_user.playlists.find(params[:id])

    if @playlist.update_attributes(playlist_params)
      redirect_to playlist_path(@playlist)
    else
      render 'edit'
    end
  end

  private
    def playlist_params
      params.require(:playlist).permit(:name, :days_ago, :limit, :days_ago_filter, :bpm, :bpm_filter, :release_date_start, :release_date_end, :genres, :plays, :plays_filter, :last_played_days_ago, :last_played_days_ago_filter, :duration, :duration_filter, :key, :danceability, :sort)
    end
end