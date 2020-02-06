class AddIndexesFollowsStreams < ActiveRecord::Migration[5.2]
  def change
    User.all.find_each do |user|
      follows_grouped = Follow.where(user_id: user.id).order('updated_at DESC').group_by{|model| [model.user_id,model.track_id] }

      follows_grouped.values.each do |duplicates|
        # the first one we want to keep right?
        first_one = duplicates.shift # or pop for last one
        # if there are any more left, they are duplicates
        # so delete all of them4
        duplicates.each{|double| double.destroy} # duplicates can now be destroyed
      end

      streams_grouped = Stream.where(user_id: user.id).order('updated_at DESC').group_by{|model| [model.user_id,model.track_id,model.played_at] }

      streams_grouped.values.each do |duplicates|
        # the first one we want to keep right?
        first_one = duplicates.shift # or pop for last one
        # if there are any more left, they are duplicates
        # so delete all of them4
        duplicates.each{|double| double.destroy} # duplicates can now be destroyed
      end
    end

    remove_index :follows, name: "index_follows_on_user_id_and_track_id"

    add_index :follows, [:user_id, :track_id], unique: true
    add_index :streams, [:user_id, :track_id, :played_at], unique: true
  end
end
