require "#{Rails.root}/app/models/counter_cache"
class CreateCounterCaches < ActiveRecord::Migration
  def change
    create_table :counter_caches do |t|
      t.string :model
      t.integer :count, :default => 0

      t.timestamps
    end

    CounterCache.find_or_create_by_model("User").increment!(:count, User.count(:id))
    CounterCache.find_or_create_by_model("Level").increment!(:count, Level.count(:id))
    CounterCache.find_or_create_by_model("Content::Event").increment!(:count, Content::Event.count(:id))
    CounterCache.find_or_create_by_model("Content::Media").increment!(:count, Content::Media.count(:id))
    CounterCache.find_or_create_by_model("Content::Post").increment!(:count, Content::Post.count(:id))
    CounterCache.find_or_create_by_model("Content::Page").increment!(:count, Content::Page.count(:id))
    CounterCache.find_or_create_by_model("Content::Widget").increment!(:count, Content::Widget.count(:id))

  end
end
