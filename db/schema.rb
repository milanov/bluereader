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

ActiveRecord::Schema.define(:version => 20130222000529) do

  create_table "categories", :force => true do |t|
    t.integer "user_id", :null => false
    t.string  "name"
  end

  create_table "feeds", :force => true do |t|
    t.integer "user_id",     :null => false
    t.integer "category_id", :null => false
    t.string  "name"
    t.string  "url"
  end

  create_table "news", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "feed_id",     :null => false
    t.string   "title"
    t.string   "description"
    t.string   "url"
    t.boolean  "read"
    t.datetime "date"
  end

  create_table "settings", :force => true do |t|
    t.integer "user_id",           :null => false
    t.integer "delete_after_days"
  end

  create_table "users", :force => true do |t|
    t.string   "username",           :null => false
    t.string   "encrypted_password", :null => false
    t.string   "full_name"
    t.datetime "logged_in_at"
    t.datetime "logged_out_at"
  end

end
