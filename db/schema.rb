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

ActiveRecord::Schema.define(version: 20140616081945) do

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
    t.string   "title",            limit: 50, default: ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.string   "role",                        default: "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
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

  create_table "contracts", force: true do |t|
    t.string   "status"
    t.decimal  "price_cents",           precision: 16, scale: 0, default: 0
    t.string   "signing_user"
    t.boolean  "terms"
    t.boolean  "confirm_pricing_model"
    t.boolean  "power_of_attorney"
    t.date     "commissioning"
    t.date     "termination"
    t.decimal  "forecast_watt_hour_pa", precision: 10, scale: 0
    t.string   "mode"
    t.integer  "contracting_party_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contracts", ["contracting_party_id"], name: "index_contracts_on_contracting_party_id", using: :btree

  create_table "devices", force: true do |t|
    t.string   "image"
    t.string   "name"
    t.string   "mode"
    t.string   "law"
    t.string   "generator_type"
    t.string   "manufacturer"
    t.string   "manufacturer_product_number"
    t.string   "shop_link"
    t.string   "primary_energy"
    t.decimal  "watt_peak",                   precision: 10, scale: 0
    t.decimal  "watt_hour_pa",                precision: 10, scale: 0
    t.date     "commissioning"
    t.boolean  "mobile",                                               default: false
    t.integer  "metering_point_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "distribution_system_operator_contracts", force: true do |t|
    t.string   "name"
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
    t.string   "customer_number"
    t.string   "contract_number"
    t.decimal  "forecast_watt_hour_pa", precision: 10, scale: 0
    t.integer  "metering_point_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "electricity_supplier_contracts", ["metering_point_id"], name: "index_electricity_supplier_contracts_on_metering_point_id", using: :btree
  add_index "electricity_supplier_contracts", ["organization_id"], name: "index_electricity_supplier_contracts_on_organization_id", using: :btree

  create_table "equipment", force: true do |t|
    t.string   "device_kind"
    t.string   "device_type"
    t.string   "ownership"
    t.date     "build"
    t.date     "calibrated_till"
    t.string   "manufacturer_name"
    t.string   "manufacturer_product_number"
    t.string   "manufacturer_device_number"
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
    t.string   "slug"
    t.string   "image"
    t.string   "name"
    t.boolean  "new_habitation",  default: false
    t.date     "inhabited_since"
    t.boolean  "active",          default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "metering_point_operator_contracts", force: true do |t|
    t.string   "customer_number"
    t.string   "contract_number"
    t.string   "username"
    t.string   "password"
    t.integer  "metering_point_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "uid"
    t.integer  "position"
    t.string   "address_addition"
    t.string   "mode"
    t.string   "voltage_level"
    t.date     "regular_reeding"
    t.string   "regular_interval"
    t.integer  "location_id"
    t.integer  "contract_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "metering_points", ["contract_id"], name: "index_metering_points_on_contract_id", using: :btree
  add_index "metering_points", ["location_id"], name: "index_metering_points_on_location_id", using: :btree

  create_table "metering_service_provider_contracts", force: true do |t|
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
    t.string   "manufacturer_product_number"
    t.string   "manufacturer_device_number"
    t.string   "owner"
    t.string   "metering_type"
    t.string   "meter_size"
    t.string   "rate"
    t.string   "mode"
    t.string   "measurement_capture"
    t.string   "mounting_method"
    t.date     "build_year"
    t.date     "calibrated_till"
    t.boolean  "virtual",                     default: false
    t.integer  "metering_point_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meters", ["metering_point_id"], name: "index_meters_on_metering_point_id", using: :btree

  create_table "organizations", force: true do |t|
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
    t.string   "slug"
    t.string   "title"
    t.string   "image"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "phone"
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

  create_table "registers", force: true do |t|
    t.string   "obis_index"
    t.boolean  "low_loadable",      default: false
    t.string   "mode"
    t.integer  "predecimal_places", default: 8
    t.integer  "decimal_places",    default: 2
    t.integer  "meter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registers", ["meter_id"], name: "index_registers_on_meter_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "standard_profiles", force: true do |t|
    t.string   "mode"
    t.string   "category"
    t.datetime "date"
    t.decimal  "watt_hour",  precision: 10, scale: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "group_id"
    t.integer  "metering_point_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["group_id"], name: "index_users_on_group_id", using: :btree
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
