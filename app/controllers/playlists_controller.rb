class PlaylistsController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def index
    redirect_to root_path
  end
  
  def new
    @playlist = Playlist.new
  end

  def create
    @playlist = Playlist.new(playlist_params)
    @playlist.user = current_user

    params[:playlist][:filters] = JSON.parse(params[:playlist][:filters])
  
    if @playlist.update_attributes(playlist_params)
      redirect_to playlist_path(@playlist)
    else
      render 'edit'
    end
  end

  def show
    @playlist = Playlist.find_by_hashid(params[:id])

    if @playlist.public == false and @playlist.user != current_user
      redirect_to root_path
    end

    if @playlist.public == true and @playlist.user != current_user
      @hide_sidebar = true
    end

    if @playlist.tracks.blank?
      @tracks = @playlist.filtered_tracks(@playlist.user).pluck(:id)

      @tracks.each do |track|
        PlaylistTrack.create(playlist: @playlist, track_id: track)
      end
    end
    
    @tracks = @playlist.tracks

    if @playlist.limit.to_i > 250 or @playlist.limit.to_i === 0
      @tracks = @tracks.limit(250)
    end
  end

  def edit
    @playlist = current_user.playlists.find_by_hashid(params[:id])
  end

  def update
    @playlist = current_user.playlists.find_by_hashid(params[:id])

    params[:playlist][:filters] = JSON.parse(params[:playlist][:filters])

    if @playlist.update_attributes(playlist_params)
      redirect_to playlist_path(@playlist)
    else
      render 'edit'
    end
  end

  def duplicate
    @playlist = Playlist.find_by_hashid(params[:id])

    if @playlist.public == true
      new_playlist = @playlist.dup
      new_playlist.user = current_user
      new_playlist.spotify_id = nil
      new_playlist.save!

      redirect_to playlist_path(new_playlist)
    else
      redirect_to root_path
    end
  end

  def destroy
    @playlist = current_user.playlists.find_by_hashid(params[:id])
    @playlist.destroy
    redirect_to root_path, notice: "Deleted that for you!"
  end

  private
    def playlist_params
      params.require(:playlist).permit(:name, :limit, :sort, :catalog, :auto_update, :public, filters: {})
    end
end