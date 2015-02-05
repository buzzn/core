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

ActiveRecord::Schema.define(version: 20150114092836) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "addresses", force: true do |t|
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
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["addressable_id", "addressable_type"], name: "index_addressable", using: :btree

  create_table "areas", force: true do |t|
    t.string   "name"
    t.integer  "zoom",           default: 16
    t.string   "address"
    t.text     "polygons"
    t.string   "polygon_encode"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "gmaps"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "areas", ["group_id"], name: "index_areas_on_group_id", using: :btree

  create_table "assets", force: true do |t|
    t.string   "image"
    t.text     "description"
    t.integer  "position"
    t.integer  "assetable_id"
    t.string   "assetable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assets", ["assetable_id", "assetable_type"], name: "index_assetable", using: :btree

  create_table "bank_accounts", force: true do |t|
    t.string   "holder"
    t.string   "iban"
    t.string   "bic"
    t.string   "bank_name"
    t.boolean  "direct_debit"
    t.integer  "bank_accountable_id"
    t.string   "bank_accountable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bank_accounts", ["bank_accountable_id", "bank_accountable_type"], name: "index_accountable", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "commentable_id",   default: 0
    t.string   "commentable_type"
    t.string   "title"
    t.text     "body"
    t.string   "subject"
    t.integer  "user_id",          default: 0, null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "contracting_parties", force: true do |t|
    t.string   "legal_entity"
    t.integer  "sales_tax_number"
    t.float    "tax_rate"
    t.integer  "tax_number"
    t.integer  "organization_id"
    t.integer  "metering_point_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contracting_parties", ["metering_point_id"], name: "index_contracting_parties_on_metering_point_id", using: :btree
  add_index "contracting_parties", ["organization_id"], name: "index_contracting_parties_on_organization_id", using: :btree
  add_index "contracting_parties", ["user_id"], name: "index_contracting_parties_on_user_id", using: :btree

  create_table "devices", force: true do |t|
    t.string   "manufacturer_name"
    t.string   "manufacturer_product_name"
    t.string   "manufacturer_product_serialnumber"
    t.string   "mode"
    t.string   "law"
    t.string   "category"
    t.string   "shop_link"
    t.string   "primary_energy"
    t.integer  "watt_peak"
    t.decimal  "watt_hour_pa"
    t.date     "commissioning"
    t.boolean  "mobile",                            default: false
    t.integer  "metering_point_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "devices", ["metering_point_id"], name: "index_devices_on_metering_point_id", using: :btree

  create_table "distribution_system_operator_contracts", force: true do |t|
    t.string   "name"
    t.string   "status"
    t.decimal  "price_cents",       precision: 16, scale: 0, default: 0
    t.string   "bdew_code"
    t.string   "edifact_email"
    t.string   "contact_name"
    t.string   "contact_email"
    t.integer  "metering_point_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "distribution_system_operator_contracts", ["metering_point_id"], name: "index_dso_contracts_on_metering_point_id", using: :btree
  add_index "distribution_system_operator_contracts", ["organization_id"], name: "index_distribution_system_operator_contracts_on_organization_id", using: :btree

  create_table "electricity_supplier_contracts", force: true do |t|
    t.string   "tariff"
    t.integer  "price_cents",           default: 0,     null: false
    t.string   "price_currency",        default: "USD", null: false
    t.string   "status"
    t.decimal  "forecast_watt_hour_pa"
    t.date     "commissioning"
    t.date     "termination"
    t.boolean  "terms"
    t.boolean  "confirm_pricing_model"
    t.boolean  "power_of_attorney"
    t.string   "signing_user"
    t.string   "customer_number"
    t.string   "contract_number"
    t.integer  "contracting_party_id"
    t.integer  "metering_point_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "electricity_supplier_contracts", ["contracting_party_id"], name: "index_electricity_supplier_contracts_on_contracting_party_id", using: :btree
  add_index "electricity_supplier_contracts", ["metering_point_id"], name: "index_electricity_supplier_contracts_on_metering_point_id", using: :btree
  add_index "electricity_supplier_contracts", ["organization_id"], name: "index_electricity_supplier_contracts_on_organization_id", using: :btree

  create_table "equipment", force: true do |t|
    t.string   "manufacturer_name"
    t.string   "manufacturer_product_name"
    t.string   "manufacturer_product_serialnumber"
    t.string   "device_kind"
    t.string   "device_type"
    t.string   "ownership"
    t.date     "build"
    t.date     "calibrated_till"
    t.integer  "converter_constant"
    t.integer  "meter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "equipment", ["meter_id"], name: "index_equipment_on_meter_id", using: :btree

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "friendship_requests", force: true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendship_requests", ["receiver_id", "sender_id"], name: "index_friendship_requests_on_receiver_id_and_sender_id", using: :btree
  add_index "friendship_requests", ["receiver_id"], name: "index_friendship_requests_on_receiver_id", using: :btree
  add_index "friendship_requests", ["sender_id"], name: "index_friendship_requests_on_sender_id", using: :btree

  create_table "friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["friend_id", "user_id"], name: "index_friendships_on_friend_id_and_user_id", using: :btree
  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

  create_table "group_metering_point_requests", force: true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "metering_point_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_metering_point_requests", ["group_id", "user_id"], name: "index_group_metering_point_requests_on_group_id_and_user_id", using: :btree
  add_index "group_metering_point_requests", ["group_id"], name: "index_group_metering_point_requests_on_group_id", using: :btree
  add_index "group_metering_point_requests", ["metering_point_id"], name: "index_group_metering_point_requests_on_metering_point_id", using: :btree
  add_index "group_metering_point_requests", ["user_id"], name: "index_group_metering_point_requests_on_user_id", using: :btree

  create_table "group_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_users", ["group_id"], name: "index_group_users_on_group_id", using: :btree
  add_index "group_users", ["user_id"], name: "index_group_users_on_user_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "slug"
    t.string   "name"
    t.string   "mode",        default: ""
    t.boolean  "private",     default: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ilns", force: true do |t|
    t.string   "bdew"
    t.string   "eic"
    t.string   "vnb"
    t.date     "valid_begin"
    t.date     "valid_end"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ilns", ["organization_id"], name: "index_ilns_on_organization_id", using: :btree

  create_table "locations", force: true do |t|
    t.string   "token"
    t.string   "slug"
    t.boolean  "new_habitation",  default: false
    t.date     "inhabited_since"
    t.boolean  "active",          default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "metering_point_operator_contracts", force: true do |t|
    t.string   "status"
    t.decimal  "price_cents",             precision: 16, scale: 0, default: 0
    t.string   "customer_number"
    t.string   "contract_number"
    t.string   "username"
    t.string   "encrypted_password"
    t.string   "encrypted_password_salt"
    t.string   "encrypted_password_iv"
    t.boolean  "valid_credentials",                                default: false
    t.boolean  "running",                                          default: true
    t.integer  "metering_point_id"
    t.integer  "organization_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metering_point_operator_contracts", ["group_id"], name: "index_metering_point_operator_contracts_on_group_id", using: :btree
  add_index "metering_point_operator_contracts", ["metering_point_id"], name: "index_metering_point_operator_contracts_on_metering_point_id", using: :btree
  add_index "metering_point_operator_contracts", ["organization_id"], name: "index_metering_point_operator_contracts_on_organization_id", using: :btree

  create_table "metering_point_users", force: true do |t|
    t.integer  "usage",             default: 100
    t.integer  "user_id"
    t.integer  "metering_point_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metering_point_users", ["metering_point_id"], name: "index_metering_point_users_on_metering_point_id", using: :btree
  add_index "metering_point_users", ["user_id"], name: "index_metering_point_users_on_user_id", using: :btree

  create_table "metering_points", force: true do |t|
    t.string   "slug"
    t.string   "uid"
    t.string   "address_addition"
    t.string   "voltage_level"
    t.date     "regular_reeding"
    t.string   "regular_interval"
    t.string   "meter_type"
    t.string   "ancestry"
    t.integer  "location_id"
    t.integer  "contract_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metering_points", ["ancestry"], name: "index_metering_points_on_ancestry", using: :btree
  add_index "metering_points", ["contract_id"], name: "index_metering_points_on_contract_id", using: :btree
  add_index "metering_points", ["group_id"], name: "index_metering_points_on_group_id", using: :btree
  add_index "metering_points", ["location_id"], name: "index_metering_points_on_location_id", using: :btree

  create_table "metering_service_provider_contracts", force: true do |t|
    t.string   "status"
    t.decimal  "price_cents",       precision: 16, scale: 0, default: 0
    t.string   "customer_number"
    t.string   "contract_number"
    t.string   "username"
    t.string   "password"
    t.integer  "metering_point_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metering_service_provider_contracts", ["metering_point_id"], name: "index_metering_service_provider_contracts_on_metering_point_id", using: :btree
  add_index "metering_service_provider_contracts", ["organization_id"], name: "index_metering_service_provider_contracts_on_organization_id", using: :btree

  create_table "meters", force: true do |t|
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
    t.boolean  "init_first_reading",                default: false
    t.boolean  "init_reading",                      default: false
    t.integer  "metering_point_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meters", ["metering_point_id"], name: "index_meters_on_metering_point_id", using: :btree

  create_table "oauth_access_grants", force: true do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: true do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "organizations", force: true do |t|
    t.string   "slug"
    t.string   "image"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "fax"
    t.string   "description"
    t.string   "website"
    t.string   "mode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: true do |t|
    t.string   "username"
    t.string   "slug"
    t.string   "title"
    t.string   "image"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "about_me"
    t.string   "gender"
    t.string   "phone"
    t.string   "time_zone"
    t.text     "know_buzzn_from"
    t.boolean  "confirm_pricing_model"
    t.boolean  "terms"
    t.boolean  "newsletter_notifications", default: true
    t.boolean  "location_notifications",   default: true
    t.boolean  "group_notifications",      default: true
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["slug"], name: "index_profiles_on_slug", unique: true, using: :btree
  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree
  add_index "profiles", ["username"], name: "index_profiles_on_username", unique: true, using: :btree

  create_table "registers", force: true do |t|
    t.string   "mode"
    t.string   "obis_index"
    t.boolean  "variable_tariff",   default: false
    t.integer  "predecimal_places", default: 8
    t.integer  "decimal_places",    default: 2
    t.boolean  "virtual",           default: false
    t.string   "formula"
    t.integer  "meter_id"
    t.integer  "metering_point_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registers", ["meter_id"], name: "index_registers_on_meter_id", using: :btree
  add_index "registers", ["metering_point_id"], name: "index_registers_on_metering_point_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "servicing_contracts", force: true do |t|
    t.string   "tariff"
    t.string   "status"
    t.string   "signing_user"
    t.boolean  "terms"
    t.boolean  "confirm_pricing_model"
    t.boolean  "power_of_attorney"
    t.date     "commissioning"
    t.date     "termination"
    t.decimal  "forecast_watt_hour_pa"
    t.decimal  "price_cents"
    t.integer  "organization_id"
    t.integer  "contracting_party_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "servicing_contracts", ["contracting_party_id"], name: "index_servicing_contracts_on_contracting_party_id", using: :btree
  add_index "servicing_contracts", ["group_id"], name: "index_servicing_contracts_on_group_id", using: :btree
  add_index "servicing_contracts", ["organization_id"], name: "index_servicing_contracts_on_organization_id", using: :btree

  create_table "standard_profiles", force: true do |t|
    t.string   "mode"
    t.string   "category"
    t.datetime "date"
    t.decimal  "watt_hour"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.integer  "group_id"
    t.integer  "metering_point_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["group_id"], name: "index_users_on_group_id", using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["invited_by_type"], name: "index_users_on_invited_by_type", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
