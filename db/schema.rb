# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_25_170431) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "btree_gist"
  enable_extension "citext"
  enable_extension "cube"
  enable_extension "dblink"
  enable_extension "dict_int"
  enable_extension "dict_xsyn"
  enable_extension "earthdistance"
  enable_extension "fuzzystrmatch"
  enable_extension "hstore"
  enable_extension "intarray"
  enable_extension "ltree"
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "pgrowlocks"
  enable_extension "pgstattuple"
  enable_extension "plpgsql"
  enable_extension "tablefunc"
  enable_extension "unaccent"
  enable_extension "uuid-ossp"
  enable_extension "xml2"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "agglomerations", force: :cascade do |t|
    t.string "name"
    t.string "image_url"
    t.boolean "is_active", default: false
    t.string "ref_code"
  end

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "zone"
    t.string "zip_code"
    t.bigint "department_id"
    t.index ["department_id"], name: "index_areas_on_department_id"
  end

  create_table "broker_agencies", force: :cascade do |t|
    t.string "name"
    t.integer "max_period_leads", default: 100
    t.integer "current_period_leads_left", default: 100
    t.integer "default_pricing_lead", default: 6
    t.bigint "agglomeration_id"
    t.string "status", default: "test"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "current_period_provided_leads", default: 0
    t.boolean "only_dd_users", default: false
    t.index ["agglomeration_id"], name: "index_broker_agencies_on_agglomeration_id"
  end

  create_table "broker_shifts", force: :cascade do |t|
    t.integer "starting_hour"
    t.integer "ending_hour"
    t.integer "day"
    t.string "name"
    t.string "shift_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "brokers", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "email", default: "", null: false
    t.string "phone"
    t.string "agency"
    t.string "trello_id"
    t.string "trello_lead_list_id"
    t.string "trello_board_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "trello_username"
    t.string "profile_picture", default: "https://hellodingdong.com/ressources/broker_pp_default.jpg"
    t.string "description"
    t.string "alias_email"
    t.bigint "agglomeration_id"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.bigint "broker_agency_id"
    t.string "password_digest", default: "$2a$12$De7bbVU.wYt16yE5EciYB.ZF8zvUFXWgduxGuFKYiEiwkWMwpEvqi"
    t.boolean "accept_leads", default: true
    t.boolean "is_director", default: false
    t.index ["agglomeration_id"], name: "index_brokers_on_agglomeration_id"
    t.index ["broker_agency_id"], name: "index_brokers_on_broker_agency_id"
    t.index ["email"], name: "index_brokers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_brokers_on_reset_password_token", unique: true
  end

  create_table "contractors", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "profile_picture"
    t.string "phone"
    t.string "company"
    t.string "email"
    t.text "description"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name"
    t.bigint "agglomeration_id"
    t.index ["agglomeration_id"], name: "index_departments_on_agglomeration_id"
  end

  create_table "jwt_blacklists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_blacklists_on_jti"
  end

  create_table "notaries", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "profile_picture"
    t.string "phone"
    t.string "company"
    t.string "email"
    t.text "description"
  end

  create_table "nurturing_mailers", force: :cascade do |t|
    t.string "name"
    t.integer "time_frame"
    t.string "template"
    t.boolean "is_active", default: false
    t.text "description"
  end

  create_table "permanences", force: :cascade do |t|
    t.bigint "broker_id"
    t.bigint "broker_shift_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["broker_id"], name: "index_permanences_on_broker_id"
    t.index ["broker_shift_id"], name: "index_permanences_on_broker_shift_id"
  end

  create_table "properties", force: :cascade do |t|
    t.integer "price"
    t.text "description"
    t.string "link"
    t.integer "rooms_number"
    t.integer "bedrooms_number"
    t.integer "surface"
    t.string "flat_type", default: "N/C"
    t.string "agency_name", default: "N/C"
    t.string "contact_number", default: "N/C"
    t.string "reference"
    t.string "source"
    t.string "provider", default: "N/C"
    t.string "street", default: "N/C"
    t.integer "floor"
    t.string "renovated", default: "N/C"
    t.boolean "has_been_processed", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "has_elevator"
    t.text "images", default: [], array: true
    t.integer "area_id"
    t.boolean "has_terrace"
    t.boolean "has_garden"
    t.boolean "has_balcony"
    t.boolean "is_new_construction"
    t.boolean "is_last_floor"
    t.text "subway_infos"
  end

  create_table "property_links", force: :cascade do |t|
    t.bigint "property_id"
    t.string "link"
    t.string "source"
    t.text "description"
    t.text "images", default: [], array: true
    t.string "method_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["property_id"], name: "index_property_links_on_property_id"
  end

  create_table "referrals", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "phone"
    t.string "email"
    t.string "referral_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "research_areas", force: :cascade do |t|
    t.bigint "area_id"
    t.bigint "research_id"
    t.index ["area_id"], name: "index_research_areas_on_area_id"
    t.index ["research_id"], name: "index_research_areas_on_research_id"
  end

  create_table "researches", force: :cascade do |t|
    t.string "name"
    t.integer "min_floor", default: 0
    t.boolean "has_elevator"
    t.integer "min_elevator_floor"
    t.integer "min_surface"
    t.integer "min_rooms_number"
    t.integer "max_price"
    t.integer "min_price"
    t.integer "max_sqm_price"
    t.boolean "is_active", default: true
    t.boolean "balcony", default: false
    t.boolean "terrace", default: false
    t.boolean "garden", default: false
    t.boolean "new_construction", default: false
    t.boolean "last_floor", default: false
    t.boolean "home_type", default: true
    t.boolean "apartment_type", default: true
    t.bigint "subscriber_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "soon_deleted_agglomeration"
    t.bigint "agglomeration_id"
    t.index ["agglomeration_id"], name: "index_researches_on_agglomeration_id"
    t.index ["subscriber_id"], name: "index_researches_on_subscriber_id"
  end

  create_table "saved_properties", force: :cascade do |t|
    t.bigint "research_id"
    t.bigint "property_id"
    t.index ["property_id"], name: "index_saved_properties_on_property_id"
    t.index ["research_id"], name: "index_saved_properties_on_research_id"
  end

  create_table "scraper_parameters", force: :cascade do |t|
    t.string "url"
    t.string "source"
    t.string "main_page_cls"
    t.string "scraper_type", default: "Static"
    t.string "waiting_cls"
    t.boolean "multi_page", default: false
    t.integer "page_nbr", default: 1
    t.string "http_type"
    t.text "http_request", default: [], array: true
    t.boolean "is_active", default: true
    t.string "zone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "group_type"
    t.boolean "high_priority", default: true
  end

  create_table "sequence_steps", force: :cascade do |t|
    t.integer "step"
    t.string "name"
    t.text "description"
    t.string "step_type"
    t.integer "time_frame"
    t.bigint "sequence_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "content"
    t.string "subject"
    t.index ["sequence_id"], name: "index_sequence_steps_on_sequence_id"
  end

  create_table "sequences", force: :cascade do |t|
    t.string "name"
    t.string "sender_email"
    t.string "sender_name"
    t.string "source"
    t.boolean "is_active"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.string "marketing_type"
    t.string "marketing_link"
  end

  create_table "specific_area_broker_agencies", force: :cascade do |t|
    t.bigint "broker_agency_id"
    t.bigint "area_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["area_id"], name: "index_specific_area_broker_agencies_on_area_id"
    t.index ["broker_agency_id"], name: "index_specific_area_broker_agencies_on_broker_agency_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "status_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "subscriber_notes", force: :cascade do |t|
    t.text "content"
    t.bigint "subscriber_id"
    t.datetime "created_at", null: false
    t.index ["subscriber_id"], name: "index_subscriber_notes_on_subscriber_id"
  end

  create_table "subscriber_sequences", force: :cascade do |t|
    t.bigint "sequence_id", null: false
    t.bigint "subscriber_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "agglomeration_id"
    t.index ["agglomeration_id"], name: "index_subscriber_sequences_on_agglomeration_id"
    t.index ["sequence_id"], name: "index_subscriber_sequences_on_sequence_id"
    t.index ["subscriber_id"], name: "index_subscriber_sequences_on_subscriber_id"
  end

  create_table "subscriber_statuses", force: :cascade do |t|
    t.bigint "status_id"
    t.bigint "subscriber_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["status_id"], name: "index_subscriber_statuses_on_status_id"
    t.index ["subscriber_id"], name: "index_subscriber_statuses_on_subscriber_id"
  end

  create_table "subscribers", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.string "phone"
    t.string "facebook_id"
    t.boolean "is_active", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "broker_id"
    t.string "trello_id_card"
    t.boolean "is_blocked"
    t.boolean "terrace", default: false
    t.string "status"
    t.boolean "messenger_flux"
    t.boolean "email_flux"
    t.boolean "email_confirmed", default: false
    t.string "confirm_token"
    t.bigint "contractor_id"
    t.bigint "notary_id"
    t.boolean "is_broker_affiliated", default: false
    t.boolean "hot_lead", default: false
    t.boolean "checked_by_broker", default: false
    t.boolean "has_stopped", default: false
    t.datetime "has_stopped_at"
    t.string "broker_status", default: "Non trait??"
    t.text "broker_comment", default: ""
    t.datetime "broker_meeting"
    t.string "password_digest"
    t.string "auth_token"
    t.index ["auth_token"], name: "index_subscribers_on_auth_token", unique: true
    t.index ["broker_id"], name: "index_subscribers_on_broker_id"
    t.index ["contractor_id"], name: "index_subscribers_on_contractor_id"
    t.index ["notary_id"], name: "index_subscribers_on_notary_id"
  end

  create_table "subways", force: :cascade do |t|
    t.string "name"
    t.string "line", default: "{}"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "areas", "departments"
  add_foreign_key "properties", "areas"
  add_foreign_key "property_links", "properties"
  add_foreign_key "sequence_steps", "sequences"
  add_foreign_key "subscriber_notes", "subscribers"
  add_foreign_key "subscriber_sequences", "sequences"
  add_foreign_key "subscriber_sequences", "subscribers"
end
