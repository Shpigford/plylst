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
  has_many :albums, through: :tracks
  has_many :streams
  has_many :playlists
  has_many :tracks, through: :follows
  has_many :artists, through: :tracks, join_table: :follows

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
      if pop_genres.present?
        pop_genres_count = Hash.new { |h, k| h[k] = 0 }
        pop_genres.flatten!
        pop_genres.each { |genre| pop_genres_count[genre] += 1 }
        pop_genres_count
          .sort_by { |k, v| -v }
          .first(1000)
          .map(&:first)
      else
        []
      end
    end

    if self.genres.present?
      JSON.parse(self.genres) + pop_genres
    else
      pop_genres
    end.uniq.sort_by(&:downcase)
  end
end
