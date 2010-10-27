# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101027121904) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "partner_id"
    t.string   "type",                 :limit => 60
    t.string   "status",               :limit => 8
    t.integer  "priority_id"
    t.datetime "created_at"
    t.boolean  "is_user_only",                       :default => false
    t.integer  "comments_count",                     :default => 0
    t.integer  "activity_id"
    t.integer  "other_user_id"
    t.integer  "tag_id"
    t.integer  "revision_id"
    t.integer  "document_id"
    t.integer  "document_revision_id"
    t.datetime "changed_at"
    t.integer  "question_id"
    t.string   "cached_issue_list"
    t.boolean  "unanswered_question",                :default => false
  end

  add_index "activities", ["activity_id"], :name => "activity_activity_id"
  add_index "activities", ["cached_issue_list"], :name => "index_activities_on_cached_issue_list"
  add_index "activities", ["changed_at"], :name => "index_activities_on_changed_at"
  add_index "activities", ["created_at"], :name => "created_at"
  add_index "activities", ["document_id"], :name => "index_activities_on_document_id"
  add_index "activities", ["document_revision_id"], :name => "index_activities_on_document_revision_id"
  add_index "activities", ["is_user_only"], :name => "activity_is_user_only_index"
  add_index "activities", ["priority_id"], :name => "activity_priority_id_index"
  add_index "activities", ["question_id"], :name => "index_activities_on_question_id"
  add_index "activities", ["revision_id"], :name => "index_activities_on_revision_id"
  add_index "activities", ["status"], :name => "activity_status_index"
  add_index "activities", ["type"], :name => "activity_type_index"
  add_index "activities", ["user_id"], :name => "activity_user_id_index"

  create_table "admins", :force => true do |t|
    t.integer "national_identity", :null => false
  end

  add_index "admins", ["national_identity"], :name => "index_admins_on_national_identity"

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          :limit => 50
    t.string   "secret",       :limit => 50
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true

  create_table "comments", :force => true do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.string   "status"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address"
    t.string   "user_agent"
    t.string   "referrer"
    t.text     "content_html"
    t.integer  "flags_count",       :default => 0
    t.string   "cached_issue_list"
  end

  add_index "comments", ["activity_id"], :name => "comments_activity_id"
  add_index "comments", ["cached_issue_list"], :name => "index_comments_on_cached_issue_list"
  add_index "comments", ["status", "activity_id"], :name => "index_comments_on_status_and_activity_id"
  add_index "comments", ["status"], :name => "comments_status"
  add_index "comments", ["user_id"], :name => "comments_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_revisions", :force => true do |t|
    t.integer  "document_id"
    t.integer  "user_id"
    t.integer  "value",                       :default => 0, :null => false
    t.string   "status",       :limit => 30
    t.string   "name",         :limit => 60
    t.string   "ip_address",   :limit => 16
    t.string   "user_agent",   :limit => 150
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content"
    t.text     "content_diff"
    t.integer  "word_count",                  :default => 0
    t.text     "content_html"
  end

  add_index "document_revisions", ["document_id"], :name => "index_document_revisions_on_document_id"
  add_index "document_revisions", ["status"], :name => "index_document_revisions_on_status"
  add_index "document_revisions", ["user_id"], :name => "index_document_revisions_on_user_id"

  create_table "documents", :force => true do |t|
    t.integer  "revision_id"
    t.integer  "priority_id"
    t.integer  "user_id"
    t.integer  "value",                           :default => 0
    t.string   "status",            :limit => 20
    t.string   "name",              :limit => 60
    t.string   "cached_issue_list"
    t.string   "author_sentence"
    t.integer  "revisions_count",                 :default => 0
    t.integer  "discussions_count",               :default => 0
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content"
    t.integer  "word_count",                      :default => 0
    t.text     "content_html"
    t.integer  "partner_id"
    t.integer  "flags_count",                     :default => 0
  end

  add_index "documents", ["priority_id"], :name => "index_documents_on_priority_id"
  add_index "documents", ["revision_id"], :name => "index_documents_on_revision_id"
  add_index "documents", ["status"], :name => "index_documents_on_status"
  add_index "documents", ["user_id"], :name => "index_documents_on_user_id"

  create_table "email_templates", :force => true do |t|
    t.string   "name",       :limit => 50
    t.string   "subject",    :limit => 150
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_templates", ["name"], :name => "index_email_templates_on_name"

  create_table "facebook_templates", :force => true do |t|
    t.string "template_name", :null => false
    t.string "content_hash",  :null => false
    t.string "bundle_id"
  end

  add_index "facebook_templates", ["template_name"], :name => "index_facebook_templates_on_template_name", :unique => true

  create_table "feeds", :force => true do |t|
    t.string   "name"
    t.string   "website_link"
    t.string   "feed_link"
    t.string   "cached_issue_list"
    t.datetime "crawled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "following_discussions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "governments", :force => true do |t|
    t.string   "status",                         :limit => 30
    t.string   "short_name",                     :limit => 20
    t.string   "domain_name",                    :limit => 60
    t.string   "layout",                         :limit => 20
    t.string   "name",                           :limit => 60
    t.string   "tagline",                        :limit => 100
    t.string   "email",                          :limit => 100
    t.boolean  "is_public",                                     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "db_name",                        :limit => 20
    t.integer  "official_user_id"
    t.string   "official_user_short_name",       :limit => 25
    t.string   "target",                         :limit => 30
    t.boolean  "is_tags",                                       :default => true
    t.boolean  "is_facebook",                                   :default => true
    t.boolean  "is_legislators",                                :default => false
    t.string   "admin_name",                     :limit => 60
    t.string   "admin_email",                    :limit => 100
    t.string   "google_analytics_code",          :limit => 15
    t.string   "quantcast_code",                 :limit => 20
    t.string   "tags_name",                      :limit => 20,  :default => "Category"
    t.string   "briefing_name",                  :limit => 20,  :default => "Briefing Room"
    t.string   "currency_name",                  :limit => 30,  :default => "political capital"
    t.string   "currency_short_name",            :limit => 3,   :default => "pc"
    t.string   "homepage",                       :limit => 20,  :default => "top"
    t.integer  "priorities_count",                              :default => 0
    t.integer  "questions_count",                               :default => 0
    t.integer  "documents_count",                               :default => 0
    t.integer  "users_count",                                   :default => 0
    t.integer  "contributors_count",                            :default => 0
    t.integer  "partners_count",                                :default => 0
    t.integer  "official_user_priorities_count",                :default => 0
    t.integer  "endorsements_count",                            :default => 0
    t.integer  "picture_id"
    t.integer  "color_scheme_id",                               :default => 1
    t.string   "mission",                        :limit => 200
    t.string   "prompt",                         :limit => 100
    t.integer  "buddy_icon_id"
    t.integer  "fav_icon_id"
    t.boolean  "is_suppress_empty_priorities",                  :default => false
    t.string   "tags_page",                      :limit => 20,  :default => "list"
    t.string   "facebook_api_key",               :limit => 32
    t.string   "facebook_secret_key",            :limit => 32
    t.string   "windows_appid",                  :limit => 32
    t.string   "windows_secret_key",             :limit => 32
    t.string   "yahoo_appid",                    :limit => 40
    t.string   "yahoo_secret_key",               :limit => 32
    t.integer  "default_branch_id"
    t.boolean  "is_twitter",                                    :default => true
    t.string   "twitter_key",                    :limit => 46
    t.string   "twitter_secret_key",             :limit => 46
    t.string   "language_code",                  :limit => 2,   :default => "en"
    t.string   "password",                       :limit => 40
    t.string   "logo_file_name"
    t.string   "logo_content_type",              :limit => 30
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "buddy_icon_file_name"
    t.string   "buddy_icon_content_type",        :limit => 30
    t.integer  "buddy_icon_file_size"
    t.datetime "buddy_icon_updated_at"
    t.string   "fav_icon_file_name"
    t.string   "fav_icon_content_type",          :limit => 30
    t.integer  "fav_icon_file_size"
    t.datetime "fav_icon_updated_at"
  end

  add_index "governments", ["domain_name"], :name => "index_governments_on_domain_name"
  add_index "governments", ["short_name"], :name => "index_governments_on_short_name"

  create_table "notifications", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "status",          :limit => 20
    t.string   "type",            :limit => 60
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sent_at"
    t.datetime "read_at"
    t.datetime "processed_at"
    t.datetime "deleted_at"
  end

  add_index "notifications", ["notifiable_type", "notifiable_id"], :name => "index_notifications_on_notifiable_type_and_notifiable_id"
  add_index "notifications", ["recipient_id"], :name => "index_notifications_on_recipient_id"
  add_index "notifications", ["sender_id"], :name => "index_notifications_on_sender_id"
  add_index "notifications", ["status", "type"], :name => "index_notifications_on_status_and_type"

  create_table "pictures", :force => true do |t|
    t.string   "name",         :limit => 200
    t.integer  "height",       :limit => 8
    t.integer  "width",        :limit => 8
    t.string   "content_type", :limit => 100
    t.binary   "data",         :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "priorities", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",                :limit => 250
    t.string   "status",              :limit => 50
    t.string   "ip_address",          :limit => 16
    t.datetime "deleted_at"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_issue_list"
    t.integer  "questions_count",                    :default => 0
    t.integer  "discussions_count",                  :default => 0
    t.integer  "relationships_count",                :default => 0
    t.datetime "status_changed_at"
    t.integer  "documents_count",                    :default => 0
    t.string   "short_url",           :limit => 20
    t.text     "description"
    t.integer  "flags_count",                        :default => 0
  end

  add_index "priorities", ["status"], :name => "priorities_status_index"
  add_index "priorities", ["user_id"], :name => "priorities_user_id_index"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.text     "bio"
    t.text     "bio_html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "questions", :force => true do |t|
    t.integer  "revision_id"
    t.integer  "priority_id"
    t.integer  "other_priority_id"
    t.integer  "user_id"
    t.integer  "value",                            :default => 0
    t.integer  "revisions_count",                  :default => 0
    t.string   "status",            :limit => 50
    t.string   "name",              :limit => 122
    t.text     "content"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "website"
    t.string   "author_sentence"
    t.integer  "discussions_count",                :default => 0
    t.text     "content_html"
    t.text     "answer"
    t.string   "cached_issue_list"
    t.datetime "answered_at"
    t.integer  "flags_count",                      :default => 0
  end

  add_index "questions", ["cached_issue_list"], :name => "index_questions_on_cached_issue_list"
  add_index "questions", ["other_priority_id"], :name => "index_questions_on_other_priority_id"
  add_index "questions", ["priority_id"], :name => "index_questions_on_priority_id"
  add_index "questions", ["revision_id"], :name => "index_questions_on_revision_id"
  add_index "questions", ["status"], :name => "index_questions_on_status"
  add_index "questions", ["user_id"], :name => "index_questions_on_user_id"

  create_table "relationships", :force => true do |t|
    t.integer  "priority_id"
    t.integer  "other_priority_id"
    t.string   "type",              :limit => 70
    t.integer  "percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["other_priority_id"], :name => "relationships_other_priority_index"
  add_index "relationships", ["priority_id"], :name => "relationships_priority_index"
  add_index "relationships", ["type"], :name => "relationships_type_index"

  create_table "revisions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "value",                            :default => 0, :null => false
    t.string   "status",            :limit => 50
    t.string   "name",              :limit => 60
    t.text     "content"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address",        :limit => 16
    t.string   "user_agent",        :limit => 150
    t.string   "website",           :limit => 100
    t.text     "content_diff"
    t.integer  "other_priority_id"
    t.text     "content_html"
    t.integer  "question_id"
  end

  add_index "revisions", ["other_priority_id"], :name => "index_revisions_on_other_priority_id"
  add_index "revisions", ["status"], :name => "index_revisions_on_status"
  add_index "revisions", ["user_id"], :name => "index_revisions_on_user_id"

  create_table "tag_subscriptions", :id => false, :force => true do |t|
    t.integer "user_id", :null => false
    t.integer "tag_id",  :null => false
  end

  add_index "tag_subscriptions", ["tag_id"], :name => "index_tag_subscriptions_on_tag_id"
  add_index "tag_subscriptions", ["user_id"], :name => "index_tag_subscriptions_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type",   :limit => 50
    t.string   "taggable_type", :limit => 50
    t.string   "context",       :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string   "name",              :limit => 60
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "top_priority_id"
    t.integer  "priorities_count",                 :default => 0
    t.integer  "feeds_count",                      :default => 0
    t.string   "title",             :limit => 60
    t.string   "description",       :limit => 200
    t.integer  "discussions_count",                :default => 0
    t.integer  "questions_count",                  :default => 0
    t.integer  "documents_count",                  :default => 0
    t.string   "prompt",            :limit => 100
    t.string   "slug",              :limit => 60
    t.integer  "weight",                           :default => 0
    t.integer  "tag_type"
    t.integer  "external_id"
    t.integer  "external_stage",                   :default => 0
  end

  add_index "tags", ["external_id"], :name => "index_tags_on_external_id"
  add_index "tags", ["slug"], :name => "index_tags_on_slug"
  add_index "tags", ["tag_type"], :name => "index_tags_on_tag_type"
  add_index "tags", ["top_priority_id"], :name => "tag_top_priority_id_index"
  add_index "tags", ["weight"], :name => "index_tags_on_weight"

  create_table "treaty_documents", :force => true do |t|
    t.integer  "chapter",               :null => false
    t.integer  "document_content_type", :null => false
    t.integer  "negotiation_status",    :null => false
    t.integer  "document_type",         :null => false
    t.string   "title",                 :null => false
    t.string   "url",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_issue_list"
    t.string   "category"
    t.datetime "date"
  end

  add_index "treaty_documents", ["cached_issue_list"], :name => "index_treaty_documents_on_cached_issue_list"
  add_index "treaty_documents", ["category"], :name => "index_treaty_documents_on_category"

  create_table "user_contacts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "other_user_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "following_id"
    t.integer  "facebook_uid"
    t.datetime "sent_at"
    t.datetime "accepted_at"
    t.boolean  "is_from_realname",               :default => false
    t.string   "status",           :limit => 30
  end

  add_index "user_contacts", ["email"], :name => "index_user_contacts_on_email"
  add_index "user_contacts", ["facebook_uid"], :name => "index_user_contacts_on_facebook_uid"
  add_index "user_contacts", ["following_id"], :name => "index_user_contacts_on_following_id"
  add_index "user_contacts", ["other_user_id"], :name => "index_user_contacts_on_other_user_id"
  add_index "user_contacts", ["status"], :name => "index_user_contacts_on_status"
  add_index "user_contacts", ["user_id"], :name => "user_contacts_user_id_index"

  create_table "users", :force => true do |t|
    t.string   "login",                      :limit => 40
    t.string   "email",                      :limit => 100
    t.string   "crypted_password",           :limit => 40
    t.string   "salt",                       :limit => 40
    t.string   "first_name",                 :limit => 100
    t.string   "last_name",                  :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "activated_at"
    t.string   "activation_code",            :limit => 60
    t.string   "remember_token",             :limit => 60
    t.datetime "remember_token_expires_at"
    t.integer  "picture_id"
    t.string   "status",                     :limit => 30,  :default => "passive"
    t.datetime "deleted_at"
    t.string   "ip_address",                 :limit => 16
    t.datetime "loggedin_at"
    t.string   "zip",                        :limit => 10
    t.date     "birth_date"
    t.string   "twitter_login",              :limit => 15
    t.string   "website",                    :limit => 150
    t.boolean  "is_mergeable",                              :default => true
    t.integer  "referral_id"
    t.boolean  "is_subscribed",                             :default => true
    t.string   "user_agent",                 :limit => 200
    t.string   "referrer",                   :limit => 200
    t.boolean  "is_tagger",                                 :default => false
    t.integer  "comments_count",                            :default => 0
    t.float    "score",                                     :default => 0.1
    t.integer  "twitter_count",                             :default => 0
    t.integer  "ignorers_count",                            :default => 0
    t.integer  "ignorings_count",                           :default => 0
    t.integer  "partner_referral_id"
    t.integer  "ads_count",                                 :default => 0
    t.integer  "changes_count",                             :default => 0
    t.string   "google_token",               :limit => 30
    t.integer  "contacts_count",                            :default => 0
    t.integer  "contacts_members_count",                    :default => 0
    t.integer  "contacts_invited_count",                    :default => 0
    t.integer  "contacts_not_invited_count",                :default => 0
    t.datetime "google_crawled_at"
    t.integer  "facebook_uid",               :limit => 8
    t.string   "city",                       :limit => 80
    t.string   "state",                      :limit => 50
    t.integer  "documents_count",                           :default => 0
    t.integer  "document_revisions_count",                  :default => 0
    t.integer  "questions_count",                           :default => 0
    t.string   "rss_code",                   :limit => 40
    t.integer  "point_revisions_count",                     :default => 0
    t.string   "address",                    :limit => 100
    t.integer  "warnings_count",                            :default => 0
    t.datetime "probation_at"
    t.datetime "suspended_at"
    t.integer  "referrals_count",                           :default => 0
    t.boolean  "is_admin",                                  :default => false
    t.integer  "branch_id"
    t.integer  "twitter_id"
    t.string   "twitter_token",              :limit => 64
    t.string   "twitter_secret",             :limit => 64
    t.datetime "twitter_crawled_at"
    t.string   "buddy_icon_file_name"
    t.string   "buddy_icon_content_type",    :limit => 30
    t.integer  "buddy_icon_file_size"
    t.datetime "buddy_icon_updated_at"
    t.boolean  "is_importing_contacts",                     :default => false
    t.integer  "imported_contacts_count",                   :default => 0
    t.boolean  "reports_enabled",                           :default => false
    t.boolean  "reports_discussions",                       :default => false
    t.boolean  "reports_questions",                         :default => false
    t.boolean  "reports_documents",                         :default => false
    t.integer  "reports_interval"
    t.string   "national_identity",                                                :null => false
    t.boolean  "have_sent_welcome",                         :default => false
    t.boolean  "is_comments_subscribed",                    :default => true
    t.datetime "last_sent_report"
    t.boolean  "reports_treaty_documents",                  :default => false
  end

  add_index "users", ["facebook_uid"], :name => "index_users_on_facebook_uid"
  add_index "users", ["national_identity"], :name => "index_users_on_national_identity", :unique => true
  add_index "users", ["rss_code"], :name => "index_users_on_rss_code"
  add_index "users", ["status"], :name => "status"
  add_index "users", ["twitter_id"], :name => "index_users_on_twitter_id"

end
