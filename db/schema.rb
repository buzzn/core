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

ActiveRecord::Schema.define(version: 20170909015357) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"
  enable_extension "uuid-ossp"


  create_enum "contract_status", "onboarding", "approvedactive", "terminated", "ended"
  create_enum "country", "AD", "AE", "AF", "AG", "AI", "AL", "AM", "AO", "AQ", "AR", "AS", "AT", "AU", "AW", "AX", "AZ", "BA", "BB", "BD", "BE", "BF", "BG", "BH", "BI", "BJ", "BL", "BM", "BN", "BO", "BQ", "BR", "BS", "BT", "BV", "BW", "BY", "BZ", "CA", "CC", "CD", "CF", "CG", "CH", "CI", "CK", "CL", "CM", "CN", "CO", "CR", "CU", "CV", "CW", "CX", "CY", "CZ", "DE", "DJ", "DK", "DM", "DO", "DZ", "EC", "EE", "EG", "EH", "ER", "ES", "ET", "FI", "FJ", "FK", "FM", "FO", "FR", "GA", "GB", "GD", "GE", "GF", "GG", "GH", "GI", "GL", "GM", "GN", "GP", "GQ", "GR", "GS", "GT", "GU", "GW", "GY", "HK", "HM", "HN", "HR", "HT", "HU", "ID", "IE", "IL", "IM", "IN", "IO", "IQ", "IR", "IS", "IT", "JE", "JM", "JO", "JP", "KE", "KG", "KH", "KI", "KM", "KN", "KP", "KR", "KW", "KY", "KZ", "LA", "LB", "LC", "LI", "LK", "LR", "LS", "LT", "LU", "LV", "LY", "MA", "MC", "MD", "ME", "MF", "MG", "MH", "MK", "ML", "MM", "MN", "MO", "MP", "MQ", "MR", "MS", "MT", "MU", "MV", "MW", "MX", "MY", "MZ", "NA", "NC", "NE", "NF", "NG", "NI", "NL", "NO", "NP", "NR", "NU", "NZ", "OM", "PA", "PE", "PF", "PG", "PH", "PK", "PL", "PM", "PN", "PR", "PS", "PT", "PW", "PY", "QA", "RE", "RO", "RS", "RU", "RW", "SA", "SB", "SC", "SD", "SE", "SG", "SH", "SI", "SJ", "SK", "SL", "SM", "SN", "SO", "SR", "SS", "ST", "SV", "SX", "SY", "SZ", "TC", "TD", "TF", "TG", "TH", "TJ", "TK", "TL", "TM", "TN", "TO", "TR", "TT", "TV", "TW", "TZ", "UA", "UG", "UM", "US", "UY", "UZ", "VA", "VC", "VE", "VG", "VI", "VN", "VU", "WF", "WS", "YE", "YT", "ZA", "ZM", "ZW"
  create_enum "direction", "in", "out"
  create_enum "direction_number", "ERZ", "ZRZ"
  create_enum "edifact_cycle_interval", "MONTHLY", "YEARLY", "QUARTERLY", "HALF_YEARLY"
  create_enum "edifact_data_logging", "Z04", "Z05"
  create_enum "edifact_measurement_method", "AMR", "MMR"
  create_enum "edifact_meter_size", "Z01", "Z02", "Z03"
  create_enum "edifact_metering_type", "AHZ", "LAZ", "WSZ", "EHZ", "MAZ", "IVA"
  create_enum "edifact_mounting_method", "BKE", "DPA", "HS"
  create_enum "edifact_tariff", "ETZ", "ZTZ", "NTZ"
  create_enum "edifact_voltage_level", "E06", "E05", "E04", "E03"
  create_enum "label", "CONSUMPTION", "DEMARCATION_PV", "DEMARCATION_CHP", "PRODUCTION_PV", "PRODUCTION_CHP", "GRID_CONSUMPTION", "GRID_FEEDING", "GRID_CONSUMPTION_CORRECTED", "GRID_FEEDING_CORRECTED", "OTHER"
  create_enum "manufacturer_name", "easy_meter", "amperix", "ferraris", "other"
  create_enum "operator", "+", "-"
  create_enum "ownership", "BUZZN_SYSTEMS", "FOREIGN_OWNERSHIP", "CUSTOMER", "LEASED", "BOUGHT"
  create_enum "preferred_language", "de", "en"
  create_enum "prefix", "F", "M"
  create_enum "quality", "20", "67", "79", "187", "220", "201"
  create_enum "read_by", "BN", "SN", "SG", "VNB"
  create_enum "reason", "IOM", "COM1", "COM2", "ROM", "PMR", "COT", "COS", "CMP", "COB"
  create_enum "section", "S", "G"
  create_enum "source", "SM", "MAN"
  create_enum "state", "DE_BB", "DE_BE", "DE_BW", "DE_BY", "DE_HB", "DE_HE", "DE_HH", "DE_MV", "DE_NI", "DE_NW", "DE_RP", "DE_SH", "DE_SL", "DE_SN", "DE_ST", "DE_TH"
  create_enum "status", "Z83", "Z84", "Z86"
  create_enum "taxation", "F", "R"
  create_enum "title", "Dr.", "Prof.", "Prof. Dr."
  create_enum "unit", "Wh", "W", "m³"
  create_table "account_login_change_keys", id: :bigserial, force: :cascade do |t|
    t.text     "key",      :null=>false
    t.text     "login",    :null=>false
    t.datetime "deadline", :default=>"((now())::timestamp without time zone + '1 day'::interval)", :null=>false
  end

  create_table "account_password_change_times", id: :bigserial, force: :cascade do |t|
    t.datetime "changed_at", :default=>"now()", :null=>false
  end

  create_table "account_password_hashes", id: :bigserial, force: :cascade do |t|
    t.text "password_hash", :null=>false
  end

  create_table "account_password_reset_keys", id: :bigserial, force: :cascade do |t|
    t.text     "key",      :null=>false
    t.datetime "deadline", :default=>"((now())::timestamp without time zone + '1 day'::interval)", :null=>false
  end

  create_table "account_previous_password_hashes", id: :bigserial, force: :cascade do |t|
    t.integer "account_id",    :limit=>8
    t.text    "password_hash", :null=>false
  end

  create_table "account_remember_keys", id: :bigserial, force: :cascade do |t|
    t.text     "key",      :null=>false
    t.datetime "deadline", :default=>"((now())::timestamp without time zone + '14 days'::interval)", :null=>false
  end

  create_table "account_statuses", force: :cascade do |t|
    t.text "name", :null=>false
  end
  add_index "account_statuses", ["name"], :name=>"account_statuses_name_key", :unique=>true, :using=>:btree

  create_table "account_verification_keys", id: :bigserial, force: :cascade do |t|
    t.text     "key",          :null=>false
    t.datetime "requested_at", :default=>"now()", :null=>false
  end

  create_table "accounts", id: :bigserial, force: :cascade do |t|
    t.integer "status_id", :default=>1, :null=>false
    t.citext  "email",     :null=>false
    t.uuid    "person_id", :null=>false
  end
  add_index "accounts", ["email"], :name=>"accounts_email_index", :unique=>true, :where=>"(status_id = ANY (ARRAY[1, 2]))", :using=>:btree

# Could not dump table "addresses" because of following StandardError
#   Unknown type 'state' for column 'state'


  create_table "bank_accounts", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "slug"
    t.string   "holder"
    t.string   "encrypted_iban"
    t.string   "bic"
    t.string   "bank_name"
    t.boolean  "direct_debit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "contracting_party_id"
    t.string   "contracting_party_type"
  end
  add_index "bank_accounts", ["slug"], :name=>"index_bank_accounts_on_slug", :unique=>true, :using=>:btree

  create_table "banks", force: :cascade do |t|
    t.string "blz"
    t.string "description"
    t.string "zip"
    t.string "place"
    t.string "name"
    t.string "bic"
  end
  add_index "banks", ["bic"], :name=>"index_banks_on_bic", :using=>:btree
  add_index "banks", ["blz"], :name=>"index_banks_on_blz", :unique=>true, :using=>:btree

  create_table "billing_cycles", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.datetime "begin_date",   :null=>false
    t.datetime "end_date",     :null=>false
    t.string   "name",         :null=>false
    t.uuid     "localpool_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "billing_cycles", ["begin_date", "end_date"], :name=>"index_billing_cycles_dates", :using=>:btree

  create_table "billings", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "status",                            :null=>false
    t.integer  "total_energy_consumption_kwh",      :null=>false
    t.integer  "total_price_cents",                 :null=>false
    t.integer  "prepayments_cents",                 :null=>false
    t.integer  "receivables_cents",                 :null=>false
    t.string   "invoice_number"
    t.string   "start_reading_id",                  :null=>false
    t.string   "end_reading_id",                    :null=>false
    t.string   "device_change_reading_1_id"
    t.string   "device_change_reading_2_id"
    t.uuid     "billing_cycle_id"
    t.uuid     "localpool_power_taker_contract_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "billings", ["billing_cycle_id", "status"], :name=>"index_billings_on_billing_cycle_id_and_status", :using=>:btree
  add_index "billings", ["billing_cycle_id"], :name=>"index_billings_on_billing_cycle_id", :using=>:btree
  add_index "billings", ["localpool_power_taker_contract_id"], :name=>"index_billings_on_localpool_power_taker_contract_id", :using=>:btree
  add_index "billings", ["status"], :name=>"index_billings_on_status", :using=>:btree

  create_table "brokers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "mode",                            :null=>false
    t.string   "external_id"
    t.string   "provider_login",                  :null=>false
    t.string   "encrypted_provider_password",     :null=>false
    t.string   "encrypted_provider_token_key"
    t.string   "encrypted_provider_token_secret"
    t.uuid     "resource_id",                     :null=>false
    t.string   "resource_type",                   :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                            :null=>false
    t.string   "consumer_key"
    t.string   "consumer_secret"
  end
  add_index "brokers", ["mode", "resource_id", "resource_type"], :name=>"index_brokers", :unique=>true, :using=>:btree
  add_index "brokers", ["resource_type", "resource_id"], :name=>"index_brokers_resources", :using=>:btree

  create_table "comments", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "commentable_id"
    t.string   "commentable_type"
    t.string   "title"
    t.text     "body"
    t.string   "subject"
    t.uuid     "user_id",          :null=>false
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "likes",            :default=>0
    t.uuid     "parent_id"
    t.string   "image"
    t.string   "chart_resolution"
    t.datetime "chart_timestamp"
  end
  add_index "comments", ["commentable_id", "commentable_type"], :name=>"index_comments_on_commentable_id_and_commentable_type", :using=>:btree
  add_index "comments", ["user_id"], :name=>"index_comments_on_user_id", :using=>:btree

# Could not dump table "contracts" because of following StandardError
#   Unknown type 'contract_status' for column 'status'


  create_table "core_configs", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string "namespace", :null=>false
    t.string "key",       :null=>false
    t.string "value",     :null=>false
  end

  create_table "devices", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
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
    t.boolean  "mobile",                            :default=>false
    t.uuid     "register_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "devices", ["register_id"], :name=>"index_devices_on_register_id", :using=>:btree

  create_table "documents", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "path",               :null=>false
    t.string   "encryption_details", :null=>false
    t.datetime "created_at",         :null=>false
    t.datetime "updated_at",         :null=>false
  end
  add_index "documents", ["path"], :name=>"index_documents_on_path", :unique=>true, :using=>:btree

  create_table "energy_classifications", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "tariff_name"
    t.float    "nuclear_ratio",                   :null=>false
    t.float    "coal_ratio",                      :null=>false
    t.float    "gas_ratio",                       :null=>false
    t.float    "other_fossiles_ratio",            :null=>false
    t.float    "renewables_eeg_ratio",            :null=>false
    t.float    "other_renewables_ratio",          :null=>false
    t.float    "co2_emission_gramm_per_kwh",      :null=>false
    t.float    "nuclear_waste_miligramm_per_kwh", :null=>false
    t.date     "end_date"
    t.uuid     "organization_id"
    t.datetime "created_at",                      :null=>false
    t.datetime "updated_at",                      :null=>false
  end
  add_index "energy_classifications", ["organization_id"], :name=>"index_energy_classifications_on_organization_id", :using=>:btree

# Could not dump table "formula_parts" because of following StandardError
#   Unknown type 'operator' for column 'operator'


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
    t.string   "type",        :null=>false
  end
  add_index "groups", ["readable"], :name=>"index_groups_on_readable", :using=>:btree
  add_index "groups", ["slug"], :name=>"index_groups_on_slug", :unique=>true, :using=>:btree

# Could not dump table "meters" because of following StandardError
#   Unknown type 'edifact_voltage_level' for column 'edifact_voltage_level'


  create_table "oauth_access_grants", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "token",             :null=>false
    t.integer  "expires_in",        :null=>false
    t.text     "redirect_uri",      :null=>false
    t.datetime "created_at",        :null=>false
    t.datetime "revoked_at"
    t.string   "scopes"
    t.uuid     "resource_owner_id", :default=>"uuid_generate_v4()"
    t.uuid     "application_id",    :default=>"uuid_generate_v4()"
  end
  add_index "oauth_access_grants", ["token"], :name=>"index_oauth_access_grants_on_token", :unique=>true, :using=>:btree

  create_table "oauth_access_tokens", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "token",             :null=>false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        :null=>false
    t.string   "scopes"
    t.uuid     "application_id",    :default=>"uuid_generate_v4()"
    t.integer  "resource_owner_id"
  end
  add_index "oauth_access_tokens", ["refresh_token"], :name=>"index_oauth_access_tokens_on_refresh_token", :unique=>true, :using=>:btree
  add_index "oauth_access_tokens", ["token"], :name=>"index_oauth_access_tokens_on_token", :unique=>true, :using=>:btree

  create_table "oauth_applications", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",         :null=>false
    t.string   "uid",          :null=>false
    t.string   "secret",       :null=>false
    t.text     "redirect_uri", :null=>false
    t.string   "scopes",       :default=>"", :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "owner_id"
    t.string   "owner_type"
  end
  add_index "oauth_applications", ["owner_id", "owner_type"], :name=>"index_oauth_applications_on_owner_id_and_owner_type", :using=>:btree
  add_index "oauth_applications", ["uid"], :name=>"index_oauth_applications_on_uid", :unique=>true, :using=>:btree

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
    t.string   "account_number"
    t.uuid     "contact_id"
  end
  add_index "organizations", ["contact_id"], :name=>"index_organizations_on_contact_id", :using=>:btree
  add_index "organizations", ["slug"], :name=>"index_organizations_on_slug", :unique=>true, :using=>:btree

  create_table "payments", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.date    "begin_date",  :null=>false
    t.date    "end_date"
    t.integer "price_cents", :null=>false
    t.string  "cycle"
    t.string  "source"
    t.uuid    "contract_id", :null=>false
  end
  add_index "payments", ["contract_id"], :name=>"index_payments_on_contract_id", :using=>:btree

# Could not dump table "persons" because of following StandardError
#   Unknown type 'title' for column 'title'


  create_table "persons_roles", id: false, force: :cascade do |t|
    t.uuid    "person_id", :null=>false
    t.integer "role_id",   :null=>false
  end
  add_index "persons_roles", ["person_id", "role_id"], :name=>"index_persons_roles_on_person_id_and_role_id", :using=>:btree
  add_index "persons_roles", ["role_id", "person_id"], :name=>"index_persons_roles_on_role_id_and_person_id", :using=>:btree

  create_table "prices", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",                                :null=>false
    t.integer  "baseprice_cents_per_month",           :null=>false
    t.float    "energyprice_cents_per_kilowatt_hour", :null=>false
    t.date     "begin_date",                          :null=>false
    t.uuid     "localpool_id"
    t.datetime "created_at",                          :null=>false
    t.datetime "updated_at",                          :null=>false
  end
  add_index "prices", ["begin_date", "localpool_id"], :name=>"index_prices_on_begin_date_and_localpool_id", :unique=>true, :using=>:btree

  create_table "profiles", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "user_name"
    t.string   "slug"
    t.string   "title"
    t.string   "image"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "about_me"
    t.string   "website"
    t.string   "gender"
    t.string   "phone"
    t.string   "time_zone"
    t.boolean  "confirm_pricing_model"
    t.boolean  "terms"
    t.string   "readable"
    t.uuid     "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "email_notification_meter_offline", :default=>false
    t.string   "address"
  end
  add_index "profiles", ["readable"], :name=>"index_profiles_on_readable", :using=>:btree
  add_index "profiles", ["slug"], :name=>"index_profiles_on_slug", :unique=>true, :using=>:btree
  add_index "profiles", ["user_id"], :name=>"index_profiles_on_user_id", :using=>:btree
  add_index "profiles", ["user_name"], :name=>"index_profiles_on_user_name", :unique=>true, :using=>:btree

# Could not dump table "readings" because of following StandardError
#   Unknown type 'unit' for column 'unit'


# Could not dump table "registers" because of following StandardError
#   Unknown type 'direction' for column 'direction'


  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.uuid     "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  add_index "roles", ["name", "resource_type", "resource_id"], :name=>"index_roles_on_name_and_resource_type_and_resource_id", :using=>:btree
  add_index "roles", ["name"], :name=>"index_roles_on_name", :using=>:btree

  create_table "schema_info", id: false, force: :cascade do |t|
    t.integer "version", :default=>0, :null=>false
  end

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
  add_index "scores", ["scoreable_id", "scoreable_type"], :name=>"index_scores_on_scoreable_id_and_scoreable_type", :using=>:btree
  add_index "scores", ["scoreable_id"], :name=>"index_scores_on_scoreable_id", :using=>:btree

  create_table "tariffs", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string  "name",                      :null=>false
    t.date    "begin_date",                :null=>false
    t.date    "end_date"
    t.integer "energyprice_cents_per_kwh", :null=>false
    t.integer "baseprice_cents_per_month", :null=>false
    t.uuid    "contract_id",               :null=>false
  end
  add_index "tariffs", ["contract_id"], :name=>"index_tariffs_on_contract_id", :using=>:btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "email",                      :default=>"", :null=>false
    t.string   "encrypted_password",         :default=>"", :null=>false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",              :default=>0, :null=>false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",            :default=>0, :null=>false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.string   "invited_by_type"
    t.integer  "invitations_count",          :default=>0
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
    t.string   "account_number"
    t.uuid     "person_id"
  end
  add_index "users", ["confirmation_token"], :name=>"index_users_on_confirmation_token", :unique=>true, :using=>:btree
  add_index "users", ["email"], :name=>"index_users_on_email", :unique=>true, :using=>:btree
  add_index "users", ["group_id"], :name=>"index_users_on_group_id", :using=>:btree
  add_index "users", ["invitation_token"], :name=>"index_users_on_invitation_token", :unique=>true, :using=>:btree
  add_index "users", ["invitations_count"], :name=>"index_users_on_invitations_count", :using=>:btree
  add_index "users", ["invited_by_type"], :name=>"index_users_on_invited_by_type", :using=>:btree
  add_index "users", ["reset_password_token"], :name=>"index_users_on_reset_password_token", :unique=>true, :using=>:btree
  add_index "users", ["unlock_token"], :name=>"index_users_on_unlock_token", :unique=>true, :using=>:btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.uuid    "user_id"
    t.integer "role_id"
  end
  add_index "users_roles", ["user_id", "role_id"], :name=>"index_users_roles_on_user_id_and_role_id", :using=>:btree

  create_table "zip_to_prices", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.integer "zip",                        :null=>false
    t.float   "price_euro_year_dt",         :null=>false
    t.float   "average_price_cents_kwh_dt", :null=>false
    t.float   "baseprice_euro_year_dt",     :null=>false
    t.float   "unitprice_cents_kwh_dt",     :null=>false
    t.float   "measurement_euro_year_dt",   :null=>false
    t.float   "baseprice_euro_year_et",     :null=>false
    t.float   "unitprice_cents_kwh_et",     :null=>false
    t.float   "measurement_euro_year_et",   :null=>false
    t.float   "ka",                         :null=>false
    t.string  "state",                      :null=>false
    t.string  "community",                  :null=>false
    t.integer "vdewid",                     :limit=>8, :null=>false
    t.string  "dso",                        :null=>false
    t.boolean "updated",                    :null=>false
  end
  add_index "zip_to_prices", ["zip"], :name=>"index_zip_to_prices_on_zip", :using=>:btree

  add_foreign_key "account_login_change_keys", "accounts", column: "id", name: "account_login_change_keys_id_fkey"
  add_foreign_key "account_password_change_times", "accounts", column: "id", name: "account_password_change_times_id_fkey"
  add_foreign_key "account_password_hashes", "accounts", column: "id", name: "account_password_hashes_id_fkey"
  add_foreign_key "account_password_reset_keys", "accounts", column: "id", name: "account_password_reset_keys_id_fkey"
  add_foreign_key "account_previous_password_hashes", "accounts", name: "account_previous_password_hashes_account_id_fkey"
  add_foreign_key "account_remember_keys", "accounts", column: "id", name: "account_remember_keys_id_fkey"
  add_foreign_key "account_verification_keys", "accounts", column: "id", name: "account_verification_keys_id_fkey"
  add_foreign_key "accounts", "account_statuses", column: "status_id", name: "accounts_status_id_fkey"
  add_foreign_key "accounts", "persons", name: "accounts_person_id_fkey"
  add_foreign_key "meters", "groups"
  add_foreign_key "organizations", "persons", column: "contact_id"
  add_foreign_key "payments", "contracts"
  add_foreign_key "readings", "registers"
  add_foreign_key "registers", "meters"
  add_foreign_key "tariffs", "contracts"
  add_foreign_key "users", "persons"
end
