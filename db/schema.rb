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

ActiveRecord::Schema.define(:version => 20170220150100) do

  create_table "account_imports", :force => true do |t|
    t.integer  "person_id",                     :null => false
    t.string   "file"
    t.boolean  "successful", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.decimal  "balance",         :precision => 8, :scale => 2, :default => 0.0
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.decimal  "credit_limit",    :precision => 8, :scale => 2
    t.decimal  "offset",          :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "paid",            :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "earned",          :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "reserve_percent", :precision => 8, :scale => 7, :default => 0.0
    t.boolean  "reserve",                                       :default => false
  end

  create_table "activities", :force => true do |t|
    t.boolean  "public"
    t.integer  "item_id"
    t.integer  "person_id"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
  end

  add_index "activities", ["item_id"], :name => "index_activities_on_item_id"
  add_index "activities", ["item_type"], :name => "index_activities_on_item_type"
  add_index "activities", ["person_id"], :name => "index_activities_on_person_id"

  create_table "activity_statuses", :force => true do |t|
    t.string   "name",        :limit => 100, :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", :force => true do |t|
    t.integer  "person_id"
    t.string   "name",            :limit => 50
    t.string   "address_line_1",  :limit => 50
    t.string   "address_line_2",  :limit => 50
    t.string   "address_line_3",  :limit => 50
    t.string   "city",            :limit => 50
    t.string   "county_id"
    t.integer  "state_id"
    t.string   "zipcode_plus_4",  :limit => 10
    t.decimal  "latitude",                      :precision => 12, :scale => 8
    t.decimal  "longitude",                     :precision => 12, :scale => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "address_privacy",                                              :default => false
    t.boolean  "primary",                                                      :default => false
  end

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "bids", :force => true do |t|
    t.integer  "req_id"
    t.integer  "person_id"
    t.integer  "status_id"
    t.decimal  "estimated_hours",              :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "actual_hours",                 :precision => 8, :scale => 2, :default => 0.0
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "accepted_at"
    t.datetime "committed_at"
    t.datetime "completed_at"
    t.datetime "approved_at"
    t.datetime "rejected_at"
    t.string   "state"
    t.text     "private_message_to_requestor"
    t.integer  "group_id"
  end

  create_table "broadcast_emails", :force => true do |t|
    t.string   "subject"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sent",       :default => false, :null => false
  end

  create_table "business_types", :force => true do |t|
    t.string   "name",        :limit => 100, :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "capabilities", :force => true do |t|
    t.integer  "group_id"
    t.integer  "oauth_token_id"
    t.string   "scope"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "invalidated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories_offers", :id => false, :force => true do |t|
    t.integer "category_id", :null => false
    t.integer "offer_id",    :null => false
  end

  add_index "categories_offers", ["category_id"], :name => "index_categories_offers_on_category_id"
  add_index "categories_offers", ["offer_id", "category_id"], :name => "index_categories_offers_on_offer_id_and_category_id"

  create_table "categories_people", :id => false, :force => true do |t|
    t.integer "category_id", :null => false
    t.integer "person_id",   :null => false
  end

  add_index "categories_people", ["category_id"], :name => "index_categories_people_on_category_id"
  add_index "categories_people", ["person_id", "category_id"], :name => "index_categories_people_on_person_id_and_category_id"

  create_table "categories_reqs", :id => false, :force => true do |t|
    t.integer "category_id", :null => false
    t.integer "req_id",      :null => false
  end

  add_index "categories_reqs", ["category_id"], :name => "index_categories_reqs_on_category_id"
  add_index "categories_reqs", ["req_id", "category_id"], :name => "index_categories_reqs_on_req_id_and_category_id"

  create_table "charges", :force => true do |t|
    t.string   "stripe_id"
    t.string   "description"
    t.float    "amount"
    t.string   "status"
    t.integer  "person_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          :limit => 50
    t.string   "secret",       :limit => 50
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true

  create_table "communications", :force => true do |t|
    t.string   "subject"
    t.text     "content"
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.datetime "sender_deleted_at"
    t.datetime "sender_read_at"
    t.datetime "recipient_deleted_at"
    t.datetime "recipient_read_at"
    t.datetime "replied_at"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "conversation_id"
  end

  add_index "communications", ["conversation_id"], :name => "index_communications_on_conversation_id"
  add_index "communications", ["recipient_id"], :name => "index_communications_on_recipient_id"
  add_index "communications", ["sender_id"], :name => "index_communications_on_sender_id"
  add_index "communications", ["type"], :name => "index_communications_on_type"

  create_table "connections", :force => true do |t|
    t.integer  "person_id"
    t.integer  "contact_id"
    t.integer  "status"
    t.datetime "accepted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connections", ["person_id", "contact_id"], :name => "index_connections_on_person_id_and_contact_id"

  create_table "conversations", :force => true do |t|
    t.integer "talkable_id"
    t.string  "talkable_type"
    t.integer "exchange_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  create_table "email_verifications", :force => true do |t|
    t.integer  "person_id"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_verifications", ["code"], :name => "index_email_verifications_on_code"

  create_table "exchanges", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "worker_id"
    t.decimal  "amount",        :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.integer  "metadata_id"
    t.string   "metadata_type"
    t.time     "deleted_at"
    t.string   "notes"
    t.boolean  "wave_all_fees",                               :default => false
  end

  create_table "fee_plans", :force => true do |t|
    t.string   "name",        :limit => 100,                    :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "available",                  :default => false
  end

  create_table "feed_posts", :force => true do |t|
    t.string   "feedid"
    t.string   "title"
    t.string   "urls"
    t.string   "categories"
    t.text     "content"
    t.string   "authors"
    t.datetime "date_published"
    t.datetime "last_updated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", :force => true do |t|
    t.integer "person_id"
    t.integer "activity_id"
  end

  add_index "feeds", ["person_id", "activity_id"], :name => "index_feeds_on_person_id_and_activity_id"

  create_table "fees", :force => true do |t|
    t.integer  "fee_plan_id"
    t.string   "type"
    t.integer  "recipient_id"
    t.decimal  "percent",      :precision => 8, :scale => 7, :default => 0.0
    t.decimal  "amount",       :precision => 8, :scale => 2, :default => 0.0
    t.string   "interval"
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
  end

  add_index "fees", ["fee_plan_id"], :name => "index_fees_on_fee_plan_id"

  create_table "form_signup_fields", :force => true do |t|
    t.string   "key"
    t.string   "title"
    t.boolean  "mandatory",  :default => false
    t.string   "field_type"
    t.integer  "order"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "options"
  end

  create_table "forums", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "topics_count",  :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.boolean  "worldwritable", :default => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "mode",                                               :default => 0,     :null => false
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "unit"
    t.boolean  "adhoc_currency",                                     :default => false
    t.boolean  "mandatory",                                          :default => false
    t.decimal  "default_credit_limit", :precision => 8, :scale => 2
    t.string   "asset"
    t.boolean  "private_txns",                                       :default => false
    t.boolean  "enable_forum",                                       :default => true
    t.boolean  "display_balance",                                    :default => true
    t.boolean  "display_earned",                                     :default => false
    t.boolean  "display_paid",                                       :default => false
    t.integer  "roles_mask"
  end

  create_table "groups_people", :id => false, :force => true do |t|
    t.integer  "group_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "group_id"
    t.integer  "person_id"
    t.datetime "accepted_at"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "local_encryption_keys", :force => true do |t|
    t.text "rsa_private_key"
    t.text "rsa_public_key"
  end

  create_table "member_preferences", :force => true do |t|
    t.boolean  "req_notifications",   :default => true
    t.boolean  "forum_notifications", :default => true
    t.integer  "membership_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "person_id"
    t.integer  "status"
    t.datetime "accepted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "roles_mask"
  end

  create_table "neighborhoods", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "neighborhoods_offers", :id => false, :force => true do |t|
    t.integer "neighborhood_id", :null => false
    t.integer "offer_id",        :null => false
  end

  add_index "neighborhoods_offers", ["neighborhood_id"], :name => "index_neighborhoods_offers_on_neighborhood_id"
  add_index "neighborhoods_offers", ["offer_id", "neighborhood_id"], :name => "index_neighborhoods_offers_on_offer_id_and_neighborhood_id"

  create_table "neighborhoods_people", :id => false, :force => true do |t|
    t.integer "neighborhood_id", :null => false
    t.integer "person_id",       :null => false
  end

  add_index "neighborhoods_people", ["neighborhood_id"], :name => "index_neighborhoods_people_on_neighborhood_id"
  add_index "neighborhoods_people", ["person_id", "neighborhood_id"], :name => "index_neighborhoods_people_on_person_id_and_neighborhood_id"

  create_table "neighborhoods_reqs", :id => false, :force => true do |t|
    t.integer "neighborhood_id", :null => false
    t.integer "req_id",          :null => false
  end

  add_index "neighborhoods_reqs", ["neighborhood_id"], :name => "index_neighborhoods_reqs_on_neighborhood_id"
  add_index "neighborhoods_reqs", ["req_id", "neighborhood_id"], :name => "index_neighborhoods_reqs_on_req_id_and_neighborhood_id"

  create_table "oauth_nonces", :force => true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "person_id"
    t.string   "type",                  :limit => 20
    t.integer  "client_application_id"
    t.string   "token",                 :limit => 50
    t.string   "secret",                :limit => 50
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "callback_url"
    t.string   "verifier",              :limit => 20
    t.string   "scope"
    t.datetime "expires_at"
    t.integer  "group_id"
  end

  add_index "oauth_tokens", ["token"], :name => "index_oauth_tokens_on_token", :unique => true

  create_table "offers", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "price",           :precision => 8, :scale => 2, :default => 0.0
    t.datetime "expiration_date"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_available",                               :default => 1
    t.integer  "available_count"
    t.integer  "group_id"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "people", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.text     "description"
    t.datetime "last_contacted_at"
    t.datetime "last_logged_in_at"
    t.integer  "forum_posts_count",        :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                    :default => false, :null => false
    t.boolean  "deactivated",              :default => false, :null => false
    t.boolean  "connection_notifications", :default => true
    t.boolean  "message_notifications",    :default => true
    t.boolean  "email_verified"
    t.string   "identity_url"
    t.string   "phone"
    t.string   "first_letter"
    t.string   "zipcode"
    t.boolean  "phoneprivacy",             :default => true
    t.string   "language"
    t.string   "openid_identifier"
    t.string   "perishable_token",         :default => "",    :null => false
    t.integer  "default_group_id"
    t.boolean  "org",                      :default => false
    t.boolean  "activator",                :default => false
    t.integer  "sponsor_id"
    t.boolean  "broadcast_emails",         :default => true,  :null => false
    t.string   "web_site_url"
    t.string   "business_name"
    t.string   "legal_business_name"
    t.integer  "business_type_id"
    t.string   "title"
    t.integer  "activity_status_id"
    t.integer  "fee_plan_id"
    t.integer  "support_contact_id"
    t.boolean  "mailchimp_subscribed",     :default => false
    t.string   "time_zone"
    t.string   "date_style"
    t.integer  "posts_per_page",           :default => 25
    t.string   "stripe_id"
    t.boolean  "requires_credit_card",     :default => true
    t.decimal  "rollover_balance",         :default => 0.0
    t.datetime "plan_started_at"
    t.string   "display_name"
    t.boolean  "visible",                  :default => true
    t.boolean  "update_card",              :default => false
    t.boolean  "junior_admin",             :default => false
  end

  add_index "people", ["admin"], :name => "index_people_on_admin"
  add_index "people", ["business_name"], :name => "index_people_on_business_name"
  add_index "people", ["deactivated"], :name => "index_people_on_deactivated"
  add_index "people", ["email"], :name => "index_people_on_email", :unique => true
  add_index "people", ["name"], :name => "index_people_on_name"
  add_index "people", ["perishable_token"], :name => "index_people_on_perishable_token"

  create_table "person_metadata", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.integer  "person_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.integer  "form_signup_field_id"
  end

  create_table "photos", :force => true do |t|
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.boolean  "primary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture"
    t.integer  "photoable_id"
    t.string   "photoable_type"
    t.string   "picture_for"
    t.boolean  "highres",        :default => true
  end

  add_index "photos", ["parent_id"], :name => "index_photos_on_parent_id"

  create_table "posts", :force => true do |t|
    t.integer  "blog_id"
    t.integer  "topic_id"
    t.integer  "person_id"
    t.string   "title"
    t.text     "body"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["blog_id"], :name => "index_posts_on_blog_id"
  add_index "posts", ["topic_id"], :name => "index_posts_on_topic_id"
  add_index "posts", ["type"], :name => "index_posts_on_type"

  create_table "preferences", :force => true do |t|
    t.boolean  "email_notifications",             :default => false, :null => false
    t.boolean  "email_verifications",             :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "analytics"
    t.string   "server_name"
    t.string   "app_name"
    t.text     "about"
    t.boolean  "demo",                            :default => false
    t.boolean  "whitelist",                       :default => false
    t.string   "gmail"
    t.text     "practice"
    t.text     "steps"
    t.text     "questions"
    t.text     "contact"
    t.string   "blog_feed_url"
    t.string   "googlemap_api_key"
    t.text     "agreement"
    t.string   "new_member_notification"
    t.text     "registration_intro"
    t.integer  "default_group_id"
    t.integer  "topic_refresh_seconds",           :default => 30,    :null => false
    t.boolean  "groups",                          :default => true,  :null => false
    t.string   "alt_signup_link"
    t.boolean  "protected_categories",            :default => false
    t.string   "mailchimp_list_id"
    t.boolean  "mailchimp_send_welcome",          :default => true
    t.string   "locale"
    t.string   "logout_url",                      :default => ""
    t.boolean  "public_uploads",                  :default => false
    t.boolean  "display_orgicon",                 :default => true
    t.boolean  "public_private_bid",              :default => false
    t.boolean  "openid",                          :default => true
    t.integer  "default_deactivated_fee_plan_id"
    t.boolean  "show_description",                :default => true
    t.boolean  "show_neighborhood",               :default => true
  end

  create_table "privacy_settings", :force => true do |t|
    t.integer  "group_id"
    t.boolean  "viewable_reqs",    :default => true
    t.boolean  "viewable_offers",  :default => true
    t.boolean  "viewable_forum",   :default => true
    t.boolean  "viewable_members", :default => true
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.string   "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_histories_on_item_and_table_and_month_and_year"

  create_table "reports", :force => true do |t|
    t.string   "type"
    t.string   "record"
    t.integer  "person_id"
    t.integer  "group_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "reqs", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "estimated_hours", :precision => 8, :scale => 2, :default => 0.0
    t.datetime "due_date"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "biddable",                                      :default => true
    t.boolean  "notifications",                                 :default => false
    t.integer  "group_id"
    t.boolean  "active",                                        :default => false
    t.boolean  "public_bid",                                    :default => false
  end

  create_table "states", :force => true do |t|
    t.string   "name",         :limit => 25, :null => false
    t.string   "abbreviation", :limit => 2,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stripe_fees", :force => true do |t|
    t.integer  "fee_plan_id"
    t.string   "type"
    t.decimal  "percent",     :precision => 8, :scale => 7, :default => 0.0
    t.decimal  "amount",      :precision => 8, :scale => 2, :default => 0.0
    t.string   "interval"
    t.string   "plan"
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
  end

  add_index "stripe_fees", ["fee_plan_id"], :name => "index_stripe_fees_on_fee_plan_id"

  create_table "system_message_templates", :force => true do |t|
    t.string   "title"
    t.string   "text"
    t.string   "message_type"
    t.string   "lang"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "time_zones", :force => true do |t|
    t.string   "time_zone"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "date_style", :default => "mm/dd/yy"
  end

  create_table "topics", :force => true do |t|
    t.integer  "forum_id"
    t.integer  "person_id"
    t.string   "name"
    t.integer  "forum_posts_count", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topics", ["forum_id"], :name => "index_topics_on_forum_id"

  create_table "viewers", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
