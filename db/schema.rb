# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130306003321) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "administrators", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "full_name"
    t.string   "phone"
    t.string   "role"
    t.text     "meta"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "administrators", ["email"], :name => "index_administrators_on_email", :unique => true
  add_index "administrators", ["reset_password_token"], :name => "index_administrators_on_reset_password_token", :unique => true

  create_table "appearance_assets", :force => true do |t|
    t.string   "filename"
    t.text     "body"
    t.string   "content_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "appearance_assets", ["content_type", "filename"], :name => "index_appearance_assets_on_content_type_and_filename"

  create_table "appearance_templates", :force => true do |t|
    t.text     "body"
    t.string   "path"
    t.string   "locale"
    t.string   "format"
    t.string   "handler"
    t.boolean  "partial"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "appearance_templates", ["path", "locale", "format", "handler", "partial"], :name => "index_appearance_templates", :unique => true

  create_table "campaigns", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "slug"
    t.integer  "campanify_id"
  end

  add_index "campaigns", ["campanify_id"], :name => "index_campaigns_on_campanify_id"

  create_table "content_event_translations", :force => true do |t|
    t.integer  "content_event_id"
    t.string   "locale"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "content_event_translations", ["content_event_id"], :name => "index_content_event_translations_on_content_event_id"
  add_index "content_event_translations", ["locale"], :name => "index_content_event_translations_on_locale"

  create_table "content_events", :force => true do |t|
    t.string   "fb_id"
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "location"
    t.text     "venue"
    t.string   "privacy"
    t.string   "parent"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "content_events", ["slug"], :name => "index_content_events_on_slug"

  create_table "content_media", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "file"
    t.integer  "user_id"
  end

  add_index "content_media", ["user_id"], :name => "index_content_media_on_user_id"

  create_table "content_medium_translations", :force => true do |t|
    t.integer  "content_medium_id"
    t.string   "locale"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "content_medium_translations", ["content_medium_id"], :name => "index_content_medium_translations_on_content_medium_id"
  add_index "content_medium_translations", ["locale"], :name => "index_content_medium_translations_on_locale"

  create_table "content_page_translations", :force => true do |t|
    t.integer  "content_page_id"
    t.string   "locale"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "content_page_translations", ["content_page_id"], :name => "index_content_page_translations_on_content_page_id"
  add_index "content_page_translations", ["locale"], :name => "index_content_page_translations_on_locale"

  create_table "content_pages", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "body"
    t.datetime "published_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "content_pages", ["slug", "published_at"], :name => "index_content_pages_on_slug_and_published_at"

  create_table "content_posts", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "body"
    t.datetime "published_at"
    t.integer  "user_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "popularity",   :default => 0
  end

  add_index "content_posts", ["slug", "published_at", "user_id"], :name => "index_content_posts_on_slug_and_published_at_and_user_id"

  create_table "content_widget_translations", :force => true do |t|
    t.integer  "content_widget_id"
    t.string   "locale"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "content_widget_translations", ["content_widget_id"], :name => "index_content_widget_translations_on_content_widget_id"
  add_index "content_widget_translations", ["locale"], :name => "index_content_widget_translations_on_locale"

  create_table "content_widgets", :force => true do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "content_widgets", ["slug"], :name => "index_content_widgets_on_slug"

  create_table "counter_caches", :force => true do |t|
    t.string   "model"
    t.integer  "count",      :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "csv_imports", :force => true do |t|
    t.string   "filename"
    t.text     "results"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "history_tracks", :force => true do |t|
    t.integer  "value",       :default => 0
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "tracker"
    t.string   "ip"
    t.integer  "owner_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "history_tracks", ["target_id", "target_type", "tracker", "ip", "owner_id", "created_at"], :name => "history_index"

  create_table "levels", :force => true do |t|
    t.string   "slug"
    t.integer  "sequence"
    t.text     "meta"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "levels", ["sequence"], :name => "index_levels_on_sequence"
  add_index "levels", ["slug"], :name => "index_levels_on_slug"

  create_table "likers_posts", :id => false, :force => true do |t|
    t.integer "liker_id"
    t.integer "post_id"
  end

  add_index "likers_posts", ["liker_id", "post_id"], :name => "index_likers_posts_on_liker_id_and_post_id"

  create_table "points", :force => true do |t|
    t.integer  "user_id"
    t.integer  "level_id"
    t.integer  "amount"
    t.string   "source_type"
    t.integer  "source_id"
    t.string   "action"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "points", ["action"], :name => "index_points_on_action"
  add_index "points", ["level_id"], :name => "index_points_on_level_id"
  add_index "points", ["source_id"], :name => "index_points_on_source_id"
  add_index "points", ["user_id"], :name => "index_points_on_user_id"

  create_table "settings", :force => true do |t|
    t.text "data"
  end

  create_table "translations", :force => true do |t|
    t.string   "locale"
    t.string   "key"
    t.text     "value"
    t.text     "interpolations"
    t.boolean  "is_proc",        :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "translations", ["locale", "key"], :name => "index_translations_on_locale_and_key", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "", :null => false
    t.string   "encrypted_password",                   :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "authentication_token"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "full_name"
    t.string   "display_name"
    t.string   "birth_year"
    t.string   "birth_date"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "address"
    t.string   "post_code"
    t.string   "phone"
    t.string   "mobile_phone"
    t.string   "branch"
    t.string   "language"
    t.boolean  "send_updates"
    t.boolean  "legal_aggrement"
    t.string   "provider"
    t.string   "uid"
    t.string   "avatar"
    t.integer  "popularity",                           :default => 0
    t.text     "meta"
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "gender"
    t.integer  "cached_uniq_visits"
    t.integer  "cached_uniq_recruits"
    t.string   "tw_screen_name"
    t.string   "tw_token"
    t.string   "tw_secret"
    t.string   "fb_token"
    t.integer  "posts_count",                          :default => 0
    t.integer  "media_count",                          :default => 0
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["branch"], :name => "index_users_on_branch"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["country"], :name => "index_users_on_country"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
