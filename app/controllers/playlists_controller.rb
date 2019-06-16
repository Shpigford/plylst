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
    @variables = @playlist.variables

    days_ago = @variables['days_ago'].to_i
    days_ago_filter = @variables['days_ago_filter'] || 'gt'
    limit = @variables['limit'] || 200
    bpm = @variables['bpm']
    bpm_filter = @variables['bpm_filter']
    release_date_start = @variables['release_date_start']
    release_date_end = @variables['release_date_end']
    
    @tracks = current_user.tracks

    if days_ago.present?
      if days_ago_filter.present? and days_ago_filter == 'gt'
        @tracks = @tracks.where('added_at < ?', days_ago.days.ago).order('added_at ASC')
      elsif days_ago_filter == 'lt'
        @tracks = @tracks.where('added_at > ?', days_ago.days.ago).order('added_at DESC')
      end
    end

    if bpm.present?
      if bpm_filter.present? and bpm_filter == 'lt'
        @tracks = @tracks.where("(audio_features ->> 'tempo')::numeric < ?", bpm)
      else
        @tracks = @tracks.where("(audio_features ->> 'tempo')::numeric > ?", bpm)
      end
    end

    if release_date_start.present? && release_date_end.present?
      @tracks = @tracks.joins(:album).where('release_date >= ? AND release_date <= ?', release_date_start, release_date_end)
    elsif release_date_start.present?
       @tracks = @tracks.joins(:album).where('release_date >= ?', release_date_start)
    elsif release_date_end.present?
       @tracks = @tracks.joins(:album).where('release_date <= ?', release_date_end)
    end

    if limit.present?
      @tracks = @tracks.limit(limit)
    end
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
      params.require(:playlist).permit(:name, :days_ago, :limit, :days_ago_filter)
    end
end
