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

ActiveRecord::Schema.define(:version => 20111219084426) do

  create_table "app_parameters", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bar_memberships", :force => true do |t|
    t.integer  "lawyer_id"
    t.string   "bar_id"
    t.integer  "state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "card_details", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.string   "card_type"
    t.string   "card_number"
    t.string   "expire_month"
    t.string   "expire_year"
    t.string   "card_verification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", :force => true do |t|
    t.integer  "client_id",                           :null => false
    t.integer  "lawyer_id",                           :null => false
    t.datetime "start_date",                          :null => false
    t.datetime "end_date",                            :null => false
    t.integer  "billable_time"
    t.float    "lawyer_rate"
    t.float    "billed_amount",    :default => 0.0
    t.boolean  "paid_to_lawyer",   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_been_charged", :default => false
    t.text     "payment_params"
    t.float    "lawdingo_charge"
  end

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "page_title"
    t.string   "page_header"
    t.text     "content"
    t.boolean  "is_deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", :force => true do |t|
    t.integer  "client_id",       :null => false
    t.integer  "lawyer_id",       :null => false
    t.integer  "conversation_id", :null => false
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "hashed_password"
    t.string   "address"
    t.string   "skype"
    t.float    "balance",              :default => 0.0
    t.boolean  "is_online",            :default => false
    t.boolean  "is_busy",              :default => false
    t.datetime "last_login"
    t.datetime "last_online"
    t.string   "user_type",                               :null => false
    t.boolean  "is_approved",          :default => false
    t.text     "undergraduate_school"
    t.text     "law_school"
    t.text     "alma_maters"
    t.text     "practice_areas"
    t.string   "law_firm"
    t.float    "rate",                 :default => 0.0
    t.string   "payment_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "personal_tagline"
    t.string   "bar_ids"
    t.boolean  "has_payment_info",     :default => false
    t.string   "peer_id",              :default => "0"
    t.string   "first_name"
    t.string   "last_name"
  end

end
