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

ActiveRecord::Schema.define(:version => 20120730114338) do

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
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
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
    t.text     "visits"
    t.text     "recruits"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["branch"], :name => "index_users_on_branch"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["country"], :name => "index_users_on_country"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
