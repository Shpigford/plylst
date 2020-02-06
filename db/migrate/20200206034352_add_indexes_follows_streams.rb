class AddIndexesFollowsStreams < ActiveRecord::Migration[5.2]
  def change
    grouped = Follow.all.order('updated_at DESC').group_by{|model| [model.user_id,model.track_id] }

    grouped.values.each do |duplicates|
      # the first one we want to keep right?
      first_one = duplicates.shift # or pop for last one
      # if there are any more left, they are duplicates
      # so delete all of them
      duplicates.each{|double| double.destroy} # duplicates can now be destroyed
    end

    remove_index :follows, name: "index_follows_on_user_id_and_track_id"

    add_index :follows, [:user_id, :track_id], unique: true
    add_index :streams, [:user_id, :track_id, :played_at], unique: true
  end
end
