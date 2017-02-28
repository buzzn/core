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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170221112718) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "activities", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "trackable_id"
    t.string   "trackable_type"
    t.uuid     "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.uuid     "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "addresses", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "slug"
    t.string   "address"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.string   "country"
    t.float    "longitude"
    t.float    "latitude"
    t.string   "time_zone"
    t.string   "readable"
    t.uuid     "addressable_id"
    t.string   "addressable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "addition"
  end

  add_index "addresses", ["addressable_id", "addressable_type"], name: "index_addressable", using: :btree
  add_index "addresses", ["readable"], name: "index_addresses_on_readable", using: :btree
  add_index "addresses", ["slug"], name: "index_addresses_on_slug", unique: true, using: :btree

  create_table "areas", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.integer  "zoom",           default: 16
    t.string   "address"
    t.text     "polygons"
    t.string   "polygon_encode"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.uuid     "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "areas", ["group_id"], name: "index_areas_on_group_id", using: :btree

  create_table "badge_notifications", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.boolean  "read_by_user", default: false
    t.uuid     "user_id"
    t.uuid     "activity_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "badge_notifications", ["activity_id"], name: "index_badge_notifications_on_activity_id", using: :btree
  add_index "badge_notifications", ["read_by_user"], name: "index_badge_notifications_on_read_by_user", using: :btree
  add_index "badge_notifications", ["user_id"], name: "index_badge_notifications_on_user_id", using: :btree

  create_table "bank_accounts", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "slug"
    t.string   "holder"
    t.string   "encrypted_iban"
    t.string   "bic"
    t.string   "bank_name"
    t.boolean  "direct_debit"
    t.uuid     "bank_accountable_id"
    t.string   "bank_accountable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bank_accounts", ["bank_accountable_id", "bank_accountable_type"], name: "index_accountable", using: :btree
  add_index "bank_accounts", ["slug"], name: "index_bank_accounts_on_slug", unique: true, using: :btree

  create_table "banks", force: :cascade do |t|
    t.string "blz"
    t.string "description"
    t.string "zip"
    t.string "place"
    t.string "name"
    t.string "bic"
  end

  add_index "banks", ["bic"], name: "index_banks_on_bic", using: :btree
  add_index "banks", ["blz"], name: "index_banks_on_blz", unique: true, using: :btree

  create_table "brokers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "mode",                            null: false
    t.string   "external_id"
    t.string   "provider_login",                  null: false
    t.string   "encrypted_provider_password",     null: false
    t.string   "encrypted_provider_token_key"
    t.string   "encrypted_provider_token_secret"
    t.uuid     "resource_id",                     null: false
    t.string   "resource_type",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                            null: false
    t.string   "consumer_key"
    t.string   "consumer_secret"
  end

  add_index "brokers", ["mode", "resource_id", "resource_type"], name: "index_brokers", unique: true, using: :btree
  add_index "brokers", ["resource_type", "resource_id"], name: "index_brokers_resources", using: :btree

  create_table "comments", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "commentable_id"
    t.string   "commentable_type"
    t.string   "title"
    t.text     "body"
    t.string   "subject"
    t.uuid     "user_id",                      null: false
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "likes",            default: 0
    t.uuid     "parent_id"
    t.string   "image"
    t.string   "chart_resolution"
    t.datetime "chart_timestamp"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "contracts", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "slug"
    t.string   "status"
    t.integer  "forecast_kwh_pa",               limit: 8
    t.date     "signing_date"
    t.date     "end_date"
    t.boolean  "terms_accepted"
    t.boolean  "confirm_pricing_model"
    t.boolean  "power_of_attorney"
    t.string   "customer_number"
    t.string   "contract_number"
    t.string   "username"
    t.string   "encrypted_password"
    t.boolean  "valid_credentials",                       default: false
    t.uuid     "register_id"
    t.uuid     "organization_id"
    t.uuid     "localpool_id"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.boolean  "other_contract"
    t.boolean  "move_in"
    t.date     "begin_date"
    t.boolean  "authorization"
    t.text     "feedback"
    t.text     "attention_by"
    t.string   "renewable_energy_law_taxation"
    t.string   "third_party_billing_number"
    t.string   "third_party_renter_number"
    t.string   "first_master_uid"
    t.string   "second_master_uid"
    t.string   "metering_point_operator_name"
    t.string   "old_supplier_name"
    t.string   "type"
    t.date     "cancellation_date"
    t.string   "old_customer_number"
    t.string   "old_account_number"
    t.uuid     "signing_user_id"
    t.uuid     "customer_id"
    t.string   "customer_type"
    t.uuid     "contractor_id"
    t.string   "contractor_type"
  end

  add_index "contracts", ["contractor_type", "contractor_id"], name: "index_contracts_on_contractor_type_and_contractor_id", using: :btree
  add_index "contracts", ["customer_type", "customer_id"], name: "index_contracts_on_customer_type_and_customer_id", using: :btree
  add_index "contracts", ["localpool_id"], name: "index_contracts_on_localpool_id", using: :btree
  add_index "contracts", ["organization_id"], name: "index_contracts_on_organization_id", using: :btree
  add_index "contracts", ["register_id"], name: "index_contracts_on_register_id", using: :btree
  add_index "contracts", ["signing_user_id"], name: "index_contracts_on_signing_user_id", using: :btree
  add_index "contracts", ["slug"], name: "index_contracts_on_slug", unique: true, using: :btree

  create_table "conversations", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dashboard_registers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.boolean  "displayed",    default: false
    t.uuid     "dashboard_id"
    t.uuid     "register_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "dashboard_registers", ["dashboard_id"], name: "index_dashboard_registers_on_dashboard_id", using: :btree
  add_index "dashboard_registers", ["register_id"], name: "index_dashboard_registers_on_register_id", using: :btree

  create_table "dashboards", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.uuid     "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "dashboards", ["user_id"], name: "index_dashboards_on_user_id", using: :btree

  create_table "devices", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "slug"
    t.string   "manufacturer_name"
    t.string   "manufacturer_product_name"
    t.string   "manufacturer_product_serialnumber"
    t.string   "image"
    t.string   "mode"
    t.string   "law"
    t.string   "category"
    t.string   "shop_link"
    t.string   "primary_energy"
    t.integer  "watt_peak"
    t.integer  "watt_hour_pa"
    t.date     "commissioning"
    t.boolean  "mobile",                            default: false
    t.string   "readable"
    t.uuid     "register_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "devices", ["readable"], name: "index_devices_on_readable", using: :btree
  add_index "devices", ["register_id"], name: "index_devices_on_register_id", using: :btree
  add_index "devices", ["slug"], name: "index_devices_on_slug", unique: true, using: :btree

  create_table "equipment", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "slug"
    t.string   "manufacturer_name"
    t.string   "manufacturer_product_name"
    t.string   "manufacturer_product_serialnumber"
    t.string   "device_kind"
    t.string   "device_type"
    t.string   "ownership"
    t.date     "build"
    t.date     "calibrated_till"
    t.integer  "converter_constant"
    t.uuid     "meter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "equipment", ["meter_id"], name: "index_equipment_on_meter_id", using: :btree
  add_index "equipment", ["slug"], name: "index_equipment_on_slug", unique: true, using: :btree

  create_table "formula_parts", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "operator"
    t.uuid     "register_id"
    t.uuid     "operand_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "formula_parts", ["operand_id"], name: "index_formula_parts_on_operand_id", using: :btree
  add_index "formula_parts", ["register_id"], name: "index_formula_parts_on_register_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.uuid     "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "friendship_requests", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "sender_id"
    t.uuid     "receiver_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendship_requests", ["receiver_id", "sender_id"], name: "index_friendship_requests_on_receiver_id_and_sender_id", using: :btree
  add_index "friendship_requests", ["receiver_id"], name: "index_friendship_requests_on_receiver_id", using: :btree
  add_index "friendship_requests", ["sender_id"], name: "index_friendship_requests_on_sender_id", using: :btree

  create_table "friendships", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id",    null: false
    t.uuid     "friend_id",  null: false
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["friend_id", "user_id"], name: "index_friendships_on_friend_id_and_user_id", using: :btree
  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

  create_table "group_register_requests", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id"
    t.uuid     "group_id"
    t.uuid     "register_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mode"
  end

  add_index "group_register_requests", ["group_id", "user_id"], name: "index_group_register_requests_on_group_id_and_user_id", using: :btree
  add_index "group_register_requests", ["group_id"], name: "index_group_register_requests_on_group_id", using: :btree
  add_index "group_register_requests", ["register_id"], name: "index_group_register_requests_on_register_id", using: :btree
  add_index "group_register_requests", ["user_id"], name: "index_group_register_requests_on_user_id", using: :btree

  create_table "groups", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "slug"
    t.string   "name"
    t.string   "logo"
    t.string   "website"
    t.string   "image"
    t.string   "readable"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "closeness"
    t.string   "type",        null: false
  end

  add_index "groups", ["readable"], name: "index_groups_on_readable", using: :btree
  add_index "groups", ["slug"], name: "index_groups_on_slug", unique: true, using: :btree

  create_table "meters", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "slug"
    t.string   "manufacturer_name"
    t.string   "manufacturer_product_name"
    t.string   "manufacturer_product_serialnumber"
    t.string   "owner"
    t.string   "metering_type"
    t.string   "meter_size"
    t.string   "rate"
    t.string   "mode"
    t.string   "image"
    t.string   "measurement_capture"
    t.string   "mounting_method"
    t.date     "build_year"
    t.date     "calibrated_till"
    t.boolean  "smart",                             default: false
    t.boolean  "online",                            default: false
    t.boolean  "pull_readings",                     default: true
    t.boolean  "init_first_reading",                default: false
    t.boolean  "init_reading",                      default: false
    t.string   "ancestry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                                              null: false
  end

  add_index "meters", ["ancestry"], name: "index_meters_on_ancestry", using: :btree
  add_index "meters", ["slug"], name: "index_meters_on_slug", unique: true, using: :btree

  create_table "nne_vnbs", id: false, force: :cascade do |t|
    t.string  "verbandsnummer", null: false
    t.string  "typ"
    t.float   "messung_et"
    t.float   "abrechnung_et"
    t.float   "zaehler_et"
    t.float   "mp_et"
    t.float   "messung_dt"
    t.float   "abrechnung_dt"
    t.float   "zaehler_dt"
    t.float   "mp_dt"
    t.float   "arbeitspreis"
    t.float   "grundpreis"
    t.boolean "vorlaeufig"
  end

  add_index "nne_vnbs", ["verbandsnummer"], name: "index_nne_vnbs_on_verbandsnummer", unique: true, using: :btree

  create_table "notification_unsubscribers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "notification_key"
    t.string   "channel"
    t.uuid     "user_id"
    t.uuid     "trackable_id"
    t.string   "trackable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "notification_unsubscribers", ["trackable_id", "trackable_type", "notification_key"], name: "index_noti_unsub_trackable_and_key", using: :btree
  add_index "notification_unsubscribers", ["trackable_id", "trackable_type"], name: "index_noti_unsub_trackable", using: :btree
  add_index "notification_unsubscribers", ["user_id", "trackable_id", "trackable_type", "notification_key"], name: "index_noti_unsub_full", using: :btree
  add_index "notification_unsubscribers", ["user_id", "trackable_id", "trackable_type"], name: "index_noti_unsub_user_and_trackable", using: :btree
  add_index "notification_unsubscribers", ["user_id"], name: "index_notification_unsubscribers_on_user_id", using: :btree

  create_table "oauth_access_grants", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "token",                                            null: false
    t.integer  "expires_in",                                       null: false
    t.text     "redirect_uri",                                     null: false
    t.datetime "created_at",                                       null: false
    t.datetime "revoked_at"
    t.string   "scopes"
    t.uuid     "resource_owner_id", default: "uuid_generate_v4()"
    t.uuid     "application_id",    default: "uuid_generate_v4()"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "token",                                            null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",                                       null: false
    t.string   "scopes"
    t.uuid     "resource_owner_id", default: "uuid_generate_v4()"
    t.uuid     "application_id",    default: "uuid_generate_v4()"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "owner_id"
    t.string   "owner_type"
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "organizations", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "slug"
    t.string   "image"
    t.string   "name"
    t.string   "email"
    t.string   "edifactemail"
    t.string   "phone"
    t.string   "fax"
    t.string   "description"
    t.string   "website"
    t.string   "mode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "market_place_id"
    t.string   "represented_by"
    t.integer  "sales_tax_number"
    t.float    "tax_rate"
    t.integer  "tax_number"
    t.boolean  "retailer"
    t.boolean  "provider_permission"
    t.boolean  "subject_to_tax"
    t.string   "mandate_reference"
    t.string   "creditor_id"
  end

  add_index "organizations", ["slug"], name: "index_organizations_on_slug", unique: true, using: :btree

  create_table "payments", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.date    "begin_date",  null: false
    t.date    "end_date"
    t.integer "price_cents", null: false
    t.string  "cycle"
    t.string  "source"
    t.uuid    "contract_id", null: false
  end

  add_index "payments", ["contract_id"], name: "index_payments_on_contract_id", using: :btree

  create_table "profiles", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "user_name"
    t.string   "slug"
    t.string   "title"
    t.string   "image"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "about_me"
    t.string   "website"
    t.string   "facebook"
    t.string   "twitter"
    t.string   "xing"
    t.string   "linkedin"
    t.string   "gender"
    t.string   "phone"
    t.string   "time_zone"
    t.text     "know_buzzn_from"
    t.boolean  "confirm_pricing_model"
    t.boolean  "terms"
    t.string   "readable"
    t.boolean  "newsletter_notifications",         default: true
    t.boolean  "location_notifications",           default: true
    t.boolean  "group_notifications",              default: true
    t.uuid     "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "email_notification_meter_offline", default: false
  end

  add_index "profiles", ["readable"], name: "index_profiles_on_readable", using: :btree
  add_index "profiles", ["slug"], name: "index_profiles_on_slug", unique: true, using: :btree
  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree
  add_index "profiles", ["user_name"], name: "index_profiles_on_user_name", unique: true, using: :btree

  create_table "register_user_requests", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id"
    t.uuid     "register_id"
    t.string   "mode"
    t.string   "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "register_user_requests", ["mode"], name: "index_register_user_requests_on_mode", using: :btree
  add_index "register_user_requests", ["register_id"], name: "index_register_user_requests_on_register_id", using: :btree
  add_index "register_user_requests", ["user_id"], name: "index_register_user_requests_on_user_id", using: :btree

  create_table "registers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "uid"
    t.string   "mode"
    t.string   "name"
    t.string   "image"
    t.string   "voltage_level"
    t.date     "regular_reeding"
    t.string   "regular_interval"
    t.boolean  "virtual",                 default: false
    t.boolean  "is_dashboard_register",   default: false
    t.string   "readable"
    t.uuid     "meter_id"
    t.uuid     "contract_id"
    t.uuid     "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forecast_kwh_pa"
    t.boolean  "observe",                 default: false
    t.integer  "min_watt",                default: 100
    t.integer  "max_watt",                default: 5000
    t.datetime "last_observed_timestamp"
    t.boolean  "observe_offline",         default: false
    t.boolean  "external",                default: false
    t.string   "type",                                    null: false
  end

  add_index "registers", ["contract_id"], name: "index_registers_on_contract_id", using: :btree
  add_index "registers", ["group_id"], name: "index_registers_on_group_id", using: :btree
  add_index "registers", ["meter_id"], name: "index_registers_on_meter_id", using: :btree
  add_index "registers", ["readable"], name: "index_registers_on_readable", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.uuid     "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "scores", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "mode"
    t.string   "interval"
    t.datetime "interval_beginning"
    t.datetime "interval_end"
    t.float    "value"
    t.uuid     "scoreable_id"
    t.string   "scoreable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scores", ["scoreable_id", "scoreable_type"], name: "index_scores_on_scoreable_id_and_scoreable_type", using: :btree
  add_index "scores", ["scoreable_id"], name: "index_scores_on_scoreable_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.uuid     "taggable_id"
    t.string   "taggable_type"
    t.uuid     "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "tariffs", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string  "name",                      null: false
    t.date    "begin_date",                null: false
    t.date    "end_date"
    t.integer "energyprice_cents_per_kwh", null: false
    t.integer "baseprice_cents_per_month", null: false
    t.uuid    "contract_id",               null: false
  end

  add_index "tariffs", ["contract_id"], name: "index_tariffs_on_contract_id", using: :btree

  create_table "used_zip_sns", force: :cascade do |t|
    t.string   "zip"
    t.integer  "kwh"
    t.float    "price"
    t.datetime "created_at"
  end

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "email",                      default: "", null: false
    t.string   "encrypted_password",         default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",              default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",            default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.string   "invited_by_type"
    t.integer  "invitations_count",          default: 0
    t.uuid     "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.uuid     "invited_by_id"
    t.text     "invitation_message"
    t.text     "data_protection_guidelines"
    t.text     "terms_of_use"
    t.integer  "sales_tax_number"
    t.float    "tax_rate"
    t.integer  "tax_number"
    t.boolean  "retailer"
    t.boolean  "provider_permission"
    t.boolean  "subject_to_tax"
    t.string   "mandate_reference"
    t.string   "creditor_id"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["group_id"], name: "index_users_on_group_id", using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_type"], name: "index_users_on_invited_by_type", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.uuid    "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "versions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.uuid     "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "votes", force: :cascade do |t|
    t.string   "votable_type"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "votable_id"
    t.uuid     "voter_id"
  end

  create_table "zip_kas", id: false, force: :cascade do |t|
    t.string "zip", null: false
    t.float  "ka"
  end

  add_index "zip_kas", ["zip"], name: "index_zip_kas_on_zip", unique: true, using: :btree

  create_table "zip_vnbs", force: :cascade do |t|
    t.string "zip"
    t.string "place"
    t.string "verbandsnummer"
  end

  add_index "zip_vnbs", ["zip"], name: "index_zip_vnbs_on_zip", using: :btree

  add_foreign_key "contracts", "users", column: "signing_user_id"
  add_foreign_key "payments", "contracts"
  add_foreign_key "registers", "meters"
  add_foreign_key "tariffs", "contracts"
end
