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

ActiveRecord::Schema.define(:version => 20120519031444) do

  create_table "characters", :force => true do |t|
    t.string   "name"
    t.string   "server"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.date     "last_update"
    t.string   "race"
    t.string   "klass"
    t.string   "klass_color"
    t.integer  "level",           :default => 1
    t.boolean  "leveling",        :default => true
    t.integer  "achievements",    :default => 0
    t.integer  "histories_count", :default => 0
    t.string   "thumbnail"
  end

  add_index "characters", ["name", "server"], :name => "index_characters_on_name_and_server"

  create_table "histories", :force => true do |t|
    t.string   "target_page"
    t.integer  "character_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.date     "record_at"
  end

  add_index "histories", ["character_id"], :name => "index_histories_on_character_id"

end
