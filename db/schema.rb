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

ActiveRecord::Schema.define(version: 20140405002111) do

  create_table "addresses", force: true do |t|
    t.string   "address"
    t.string   "street"
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

  create_table "contracting_parties", force: true do |t|
    t.string   "legal_entity"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contracting_parties", ["user_id"], name: "index_contracting_parties_on_user_id", using: :btree

  create_table "contracts", force: true do |t|
    t.string   "metering_point"
    t.string   "signing_user"
    t.boolean  "terms"
    t.boolean  "confirm_pricing_model"
    t.boolean  "power_of_attorney"
    t.integer  "contracting_party_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contracts", ["contracting_party_id"], name: "index_contracts_on_contracting_party_id", using: :btree

  create_table "external_contracts", force: true do |t|
    t.string   "mode"
    t.string   "customer_number"
    t.string   "contract_number"
    t.integer  "external_contractable_id"
    t.string   "external_contractable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "groups", force: true do |t|
    t.string   "slug"
    t.string   "name"
    t.boolean  "private"
    t.string   "mode"
    t.integer  "meter_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meters", force: true do |t|
    t.string   "slug"
    t.string   "name"
    t.string   "uid"
    t.string   "manufacturer"
    t.integer  "contract_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meters", ["contract_id"], name: "index_meters_on_contract_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.string   "image"
    t.string   "email"
    t.string   "phone"
    t.integer  "organizationable_id"
    t.string   "organizationable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["organizationable_id", "organizationable_type"], name: "index_organizationable", using: :btree

  create_table "power_generators", force: true do |t|
    t.string   "name"
    t.string   "law"
    t.string   "brand"
    t.string   "primary_energy"
    t.decimal  "watt_peak",      precision: 10, scale: 0
    t.date     "commissioning"
    t.integer  "meter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "power_generators", ["meter_id"], name: "index_power_generators_on_meter_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "suppliers", force: true do |t|
    t.string   "name"
    t.string   "customer_number"
    t.string   "contract_number"
    t.integer  "meter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suppliers", ["meter_id"], name: "index_suppliers_on_meter_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "slug"
    t.string   "image"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "phone"
    t.boolean  "terms",                    default: false
    t.boolean  "confirm_pricing_model",    default: false
    t.boolean  "newsletter_notifications", default: true
    t.boolean  "meter_notifications",      default: true
    t.boolean  "group_notifications",      default: true
    t.string   "email",                    default: "",    null: false
    t.string   "encrypted_password",       default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",          default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
