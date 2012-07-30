class CreateTranslationTables < ActiveRecord::Migration
  def up
    Content::Page.create_translation_table! :title => :string, :body => :text
    Content::Post.create_translation_table! :title => :string, :body => :text    
    Content::Widget.create_translation_table! :title => :string, :body => :text
    Content::Media.create_translation_table! :title => :string, :description => :string    
    Content::Event.create_translation_table! :name => :string, :description => :text
  end

  def down
    Content::Page.drop_translation_table!
    Content::Post.drop_translation_table!
    Content::Widget.drop_translation_table!
    Content::Media.drop_translation_table!
    Content::Event.drop_translation_table!
  end
end
