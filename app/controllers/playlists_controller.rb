class PlaylistsController < ApplicationController
  before_action :authenticate_user!

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
    @playlist = current_user.playlists.find(params[:id])

    if @playlist.full_catalog.present?
      @tracks =  @playlist.filtered_tracks(current_user).includes(:album, :artist)
    else
      @tracks =  @playlist.filtered_tracks(current_user).includes(:album, :artist, :follows)
    end

    if @playlist.limit.to_i > 250 or @playlist.limit.to_i === 0
      @tracks = @tracks.limit(250)
    end
  end

  def edit
    @playlist = current_user.playlists.find(params[:id])
  end

  def update
    @playlist = current_user.playlists.find(params[:id])

    params[:playlist][:filters] = JSON.parse(params[:playlist][:filters])

    if @playlist.update_attributes(playlist_params)
      redirect_to playlist_path(@playlist)
    else
      render 'edit'
    end
  end

  def destroy
    @playlist = current_user.playlists.find(params[:id])
    @playlist.destroy
    redirect_to root_path, notice: "Deleted that for you!"
  end

  private
    def playlist_params
      params.require(:playlist).permit(:name, :limit, :sort, :full_catalog, :auto_update, :public, filters: {})
    end
end