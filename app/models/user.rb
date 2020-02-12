# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  email               :string           default(""), not null
#  provider            :string
#  uid                 :string
#  remember_created_at :datetime
#  sign_in_count       :integer          default(0), not null
#  current_sign_in_at  :datetime
#  last_sign_in_at     :datetime
#  current_sign_in_ip  :inet
#  last_sign_in_ip     :inet
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  settings            :string
#

class User < ApplicationRecord
  has_many :follows, dependent:  :destroy
  has_many :tracks, through: :follows
  has_many :albums, through: :tracks
  has_many :artists, through: :tracks
  has_many :streams
  has_many :playlists

  scope :active, -> {where(active:true)}

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :rememberable, :trackable, :omniauthable, :timeoutable, omniauth_providers: %i[spotify]

  serialize :settings

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
    end
  end

  def combined_genres
    pop_genres = Rails.cache.fetch("pop_genres", expires_in: 24.hours) do
      pop_genres = Artist.pluck(:genres).reject!(&:empty?)
      pop_genres = pop_genres.flatten!
      pop_genres.group_by(&:itself).map { |k,v| [k, v.count] }.to_h.sort_by{|k,v| v}.reverse.first(1000).map{|a| a.first}
    end

    if self.genres.present?
      (Array(self.genres) + pop_genres).uniq.sort_by(&:downcase)
    else
      pop_genres.uniq.sort_by(&:downcase)
    end
  end
end
