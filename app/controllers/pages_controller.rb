class PagesController < ApplicationController
  layout 'marketing', only: [:home]

  def index
    redirect_to playlists_path if user_signed_in?
  end

  def home
    
  end

  def contact
    FeedbackMailer.with(user: current_user, message: params[:message]).feedback_email.deliver if params[:message].present?
  end

  def genres
    @genres = Artist.pluck(:genres).reject!(&:empty?).flatten.group_by(&:itself).map { |k,v| [k, v.count] }.to_h.sort_by{|k,v| v}.reverse
    @hide_sidebar = true
  end

  def sitemap
    respond_to do |format|
      format.xml
    end
  end

  def sitemap_pages
    respond_to do |format|
      format.xml
    end
  end

  def sitemap_playlists
    respond_to do |format|
      format.xml
    end
  end
end
