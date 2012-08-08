class CreateHistoryTracks < ActiveRecord::Migration
  def change
    create_table :history_tracks do |t|
      t.integer :value, :default => 0   # tracking value
      t.integer :target_id               # polymorphic id
      t.string :target_type             # polymorphic type
      t.string :tracker                 # visits, recruits, likes, etc... 
      t.string :ip                      # ip
      t.integer :owner_id               # owner user id
      t.timestamps                      # timestamp
    end
    add_index :history_tracks, [:target_id, :target_type, :tracker, :ip, :owner_id, :created_at], name: "history_index"
  end
end
