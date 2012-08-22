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

ActiveRecord::Schema.define(:version => 20120822103854) do

  create_table "app_parameters", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_parameters", ["created_at"], :name => "created_at"
  add_index "app_parameters", ["name"], :name => "name"
  add_index "app_parameters", ["value"], :name => "value"

  create_table "appointments", :force => true do |t|
    t.integer  "lawyer_id"
    t.datetime "time"
    t.string   "contact_number"
    t.string   "appointment_type", :default => "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
    t.integer  "client_id"
  end

  add_index "appointments", ["appointment_type"], :name => "appointment_type"
  add_index "appointments", ["client_id"], :name => "client_id"
  add_index "appointments", ["created_at"], :name => "created_at"
  add_index "appointments", ["lawyer_id"], :name => "lawyer_id"

  create_table "bar_memberships", :force => true do |t|
    t.integer  "lawyer_id"
    t.string   "bar_id"
    t.integer  "state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bar_memberships", ["bar_id"], :name => "bar_id"
  add_index "bar_memberships", ["created_at"], :name => "created_at"
  add_index "bar_memberships", ["lawyer_id"], :name => "lawyer_id"
  add_index "bar_memberships", ["state_id"], :name => "state_id"

  create_table "bids", :force => true do |t|
    t.integer  "inquiry_id"
    t.integer  "lawyer_id"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bids", ["amount"], :name => "amount"
  add_index "bids", ["created_at"], :name => "created_at"
  add_index "bids", ["inquiry_id"], :name => "inquiry_id"
  add_index "bids", ["lawyer_id"], :name => "lawyer_id"

  create_table "calls", :force => true do |t|
    t.integer  "client_id"
    t.integer  "lawyer_id"
    t.string   "sid"
    t.string   "status"
    t.integer  "call_duration"
    t.string   "from"
    t.string   "to"
    t.datetime "start_date"
    t.datetime "billing_start_time"
    t.datetime "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conversation_id"
    t.integer  "digits"
  end

  add_index "calls", ["billing_start_time"], :name => "billing_start_time"
  add_index "calls", ["client_id"], :name => "client_id"
  add_index "calls", ["conversation_id"], :name => "conversation_id"
  add_index "calls", ["created_at"], :name => "created_at"
  add_index "calls", ["end_date"], :name => "end_date"
  add_index "calls", ["from"], :name => "from"
  add_index "calls", ["lawyer_id"], :name => "lawyer_id"
  add_index "calls", ["sid"], :name => "sid"
  add_index "calls", ["start_date"], :name => "start_date"
  add_index "calls", ["status"], :name => "status"
  add_index "calls", ["to"], :name => "to"

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

  add_index "card_details", ["city"], :name => "city"
  add_index "card_details", ["created_at"], :name => "created_at"
  add_index "card_details", ["user_id"], :name => "user_id"

  create_table "conversations", :force => true do |t|
    t.integer  "client_id",                            :null => false
    t.integer  "lawyer_id",                            :null => false
    t.datetime "start_date",                           :null => false
    t.datetime "end_date",                             :null => false
    t.integer  "billable_time"
    t.float    "lawyer_rate"
    t.float    "billed_amount",     :default => 0.0
    t.boolean  "paid_to_lawyer",    :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "has_been_charged",  :default => false
    t.text     "payment_params"
    t.float    "lawdingo_charge"
    t.string   "consultation_type"
  end

  add_index "conversations", ["billable_time"], :name => "billable_time"
  add_index "conversations", ["client_id"], :name => "client_id"
  add_index "conversations", ["consultation_type"], :name => "consultation_type"
  add_index "conversations", ["created_at"], :name => "created_at"
  add_index "conversations", ["end_date"], :name => "end_date"
  add_index "conversations", ["has_been_charged"], :name => "has_been_charged"
  add_index "conversations", ["lawdingo_charge"], :name => "lawdingo_charge"
  add_index "conversations", ["lawyer_id"], :name => "lawyer_id"
  add_index "conversations", ["lawyer_rate"], :name => "lawyer_rate"
  add_index "conversations", ["paid_to_lawyer"], :name => "paid_to_lawyer"
  add_index "conversations", ["start_date"], :name => "start_date"

  create_table "daily_hours", :force => true do |t|
    t.integer "lawyer_id"
    t.integer "wday"
    t.integer "start_time"
    t.integer "end_time"
  end

  add_index "daily_hours", ["end_time"], :name => "end_time"
  add_index "daily_hours", ["lawyer_id"], :name => "lawyer_id"
  add_index "daily_hours", ["start_time"], :name => "start_time"
  add_index "daily_hours", ["wday"], :name => "wday"

  create_table "expert_areas", :force => true do |t|
    t.integer  "lawyer_id"
    t.integer  "practice_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expert_areas", ["created_at"], :name => "created_at"
  add_index "expert_areas", ["lawyer_id"], :name => "lawyer_id"
  add_index "expert_areas", ["practice_area_id"], :name => "practice_area_id"

  create_table "framey_videos", :force => true do |t|
    t.string   "name"
    t.integer  "filesize",             :default => 0
    t.float    "duration"
    t.string   "state"
    t.integer  "views"
    t.string   "data"
    t.string   "flv_url"
    t.string   "mp4_url"
    t.string   "medium_thumbnail_url"
    t.string   "large_thumbnail_url"
    t.string   "small_thumbnail_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
  end

  add_index "framey_videos", ["created_at"], :name => "created_at"
  add_index "framey_videos", ["creator_id"], :name => "creator_id"
  add_index "framey_videos", ["name"], :name => "name"
  add_index "framey_videos", ["views"], :name => "views"

  create_table "homepage_images", :force => true do |t|
    t.integer  "lawyer_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "homepage_images", ["created_at"], :name => "created_at"
  add_index "homepage_images", ["lawyer_id"], :name => "lawyer_id"
  add_index "homepage_images", ["photo_content_type"], :name => "photo_content_type"
  add_index "homepage_images", ["photo_file_name"], :name => "photo_file_name"

  create_table "inquiries", :force => true do |t|
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_closed",   :default => false
  end

  add_index "inquiries", ["created_at"], :name => "created_at"
  add_index "inquiries", ["is_closed"], :name => "is_closed"
  add_index "inquiries", ["question_id"], :name => "question_id"

  create_table "messages", :force => true do |t|
    t.text     "body"
    t.integer  "client_id"
    t.integer  "lawyer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["client_id"], :name => "client_id"
  add_index "messages", ["created_at"], :name => "created_at"
  add_index "messages", ["lawyer_id"], :name => "lawyer_id"

  create_table "offering_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "offering_types", ["created_at"], :name => "created_at"

  create_table "offerings", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.float    "fee",              :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "practice_area_id"
  end

  add_index "offerings", ["created_at"], :name => "created_at"
  add_index "offerings", ["fee"], :name => "fee"
  add_index "offerings", ["practice_area_id"], :name => "practice_area_id"
  add_index "offerings", ["user_id"], :name => "user_id"

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "page_title"
    t.string   "page_header"
    t.text     "content"
    t.boolean  "is_deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["created_at"], :name => "created_at"
  add_index "pages", ["is_deleted"], :name => "is_deleted"

  create_table "practice_areas", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_national"
  end

  add_index "practice_areas", ["created_at"], :name => "created_at"
  add_index "practice_areas", ["is_national"], :name => "is_national"
  add_index "practice_areas", ["name"], :name => "name"
  add_index "practice_areas", ["parent_id"], :name => "parent_id"

  create_table "questions", :force => true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state_name"
    t.string   "practice_area"
  end

  add_index "questions", ["created_at"], :name => "created_at"
  add_index "questions", ["practice_area"], :name => "practice_area"
  add_index "questions", ["state_name"], :name => "state_name"
  add_index "questions", ["type"], :name => "type"
  add_index "questions", ["user_id"], :name => "user_id"

  create_table "reviews", :force => true do |t|
    t.integer  "conversation_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "purpose"
    t.integer  "rating"
    t.text     "body"
    t.integer  "lawyer_id"
  end

  add_index "reviews", ["conversation_id"], :name => "conversation_id"
  add_index "reviews", ["created_at"], :name => "created_at"
  add_index "reviews", ["lawyer_id"], :name => "lawyer_id"
  add_index "reviews", ["rating"], :name => "rating"

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.string   "rank"
    t.integer  "rank_category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schools", ["created_at"], :name => "created_at"
  add_index "schools", ["name"], :name => "name"
  add_index "schools", ["rank"], :name => "rank"
  add_index "schools", ["rank_category"], :name => "rank_category"

  create_table "searches", :force => true do |t|
    t.text     "query"
    t.integer  "user_id"
    t.integer  "count",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["user_id"], :name => "index_searches_on_user_id"

  create_table "states", :force => true do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "states", ["abbreviation"], :name => "abbreviation"
  add_index "states", ["created_at"], :name => "created_at"
  add_index "states", ["name"], :name => "name"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "hashed_password"
    t.string   "address"
    t.string   "skype"
    t.float    "balance",                                  :default => 0.0
    t.boolean  "is_online",                                :default => false
    t.boolean  "is_busy",                                  :default => false
    t.datetime "last_login"
    t.datetime "last_online"
    t.string   "user_type",                                                                          :null => false
    t.boolean  "is_approved",                              :default => false
    t.text     "undergraduate_school"
    t.text     "law_school"
    t.text     "alma_maters"
    t.string   "law_firm"
    t.float    "rate",                                     :default => 0.0
    t.string   "payment_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.text     "personal_tagline"
    t.string   "bar_ids"
    t.boolean  "has_payment_info",                         :default => false
    t.string   "peer_id",                                  :default => "0"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "stripe_customer_token"
    t.string   "phone"
    t.integer  "free_consultation_duration"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.integer  "school_id"
    t.integer  "license_year"
    t.string   "yelp_business_id"
    t.string   "time_zone",                                :default => "Pacific Time (US & Canada)"
    t.string   "tb_session_id"
    t.text     "tb_token"
    t.string   "call_status",                :limit => 50
  end

  add_index "users", ["balance"], :name => "balance"
  add_index "users", ["created_at"], :name => "created_at"
  add_index "users", ["email"], :name => "email"
  add_index "users", ["free_consultation_duration"], :name => "free_consultation_duration"
  add_index "users", ["has_payment_info"], :name => "has_payment_info"
  add_index "users", ["is_approved"], :name => "is_approved"
  add_index "users", ["is_busy"], :name => "is_busy"
  add_index "users", ["is_online"], :name => "is_online"
  add_index "users", ["last_login"], :name => "last_login"
  add_index "users", ["last_online"], :name => "last_online"
  add_index "users", ["license_year"], :name => "license_year"
  add_index "users", ["photo_file_name"], :name => "photo_file_name"
  add_index "users", ["rate"], :name => "rate"
  add_index "users", ["skype"], :name => "skype"
  add_index "users", ["updated_at"], :name => "updated_at"
  add_index "users", ["user_type"], :name => "user_type"

end
