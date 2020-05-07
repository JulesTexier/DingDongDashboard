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

ActiveRecord::Schema.define(version: 2020_05_07_162801) do

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

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "zone"
  end

  create_table "brokers", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "email"
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
  end

  create_table "districts", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "subscriber_id"
    t.bigint "property_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["property_id"], name: "index_favorites_on_property_id"
    t.index ["subscriber_id", "property_id"], name: "index_favorites_on_subscriber_id_and_property_id", unique: true
    t.index ["subscriber_id"], name: "index_favorites_on_subscriber_id"
  end

  create_table "hunter_searches", force: :cascade do |t|
    t.string "research_name"
    t.text "areas", default: [], array: true
    t.integer "min_floor", default: 0
    t.boolean "has_elevator"
    t.integer "min_elevator_floor", default: 0
    t.integer "surface"
    t.integer "rooms_number"
    t.integer "max_price"
    t.bigint "hunter_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["hunter_id"], name: "index_hunter_searches_on_hunter_id"
  end

  create_table "hunters", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.string "phone"
    t.string "company"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "leads", force: :cascade do |t|
    t.string "firstname"
    t.string "phone"
    t.string "email"
    t.boolean "has_messenger"
    t.integer "min_surface"
    t.integer "max_price"
    t.string "project_type"
    t.text "areas"
    t.text "additional_question"
    t.text "specific_criteria"
    t.string "source"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "tf_filled"
    t.bigint "broker_id"
    t.string "trello_id_card"
    t.string "lastname"
    t.integer "min_rooms_number"
    t.index ["broker_id"], name: "index_leads_on_broker_id"
  end

  create_table "properties", force: :cascade do |t|
    t.integer "price"
    t.string "old_area"
    t.string "title"
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
  end

  create_table "property_districts", force: :cascade do |t|
    t.bigint "district_id"
    t.bigint "property_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["district_id"], name: "index_property_districts_on_district_id"
    t.index ["property_id"], name: "index_property_districts_on_property_id"
  end

  create_table "property_images", force: :cascade do |t|
    t.string "url"
    t.bigint "property_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["property_id"], name: "index_property_images_on_property_id"
  end

  create_table "property_subways", force: :cascade do |t|
    t.bigint "property_id"
    t.bigint "subway_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["property_id", "subway_id"], name: "index_property_subways_on_property_id_and_subway_id", unique: true
    t.index ["property_id"], name: "index_property_subways_on_property_id"
    t.index ["subway_id"], name: "index_property_subways_on_subway_id"
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
  end

  create_table "selected_areas", force: :cascade do |t|
    t.bigint "subscriber_id"
    t.bigint "area_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["area_id"], name: "index_selected_areas_on_area_id"
    t.index ["subscriber_id", "area_id"], name: "index_selected_areas_on_subscriber_id_and_area_id", unique: true
    t.index ["subscriber_id"], name: "index_selected_areas_on_subscriber_id"
  end

  create_table "selected_districts", force: :cascade do |t|
    t.bigint "district_id"
    t.bigint "subscriber_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["district_id"], name: "index_selected_districts_on_district_id"
    t.index ["subscriber_id", "district_id"], name: "index_selected_districts_on_subscriber_id_and_district_id", unique: true
    t.index ["subscriber_id"], name: "index_selected_districts_on_subscriber_id"
  end

  create_table "sequence_steps", force: :cascade do |t|
    t.integer "step"
    t.string "name"
    t.text "description"
    t.string "step_type"
    t.integer "time_frame"
    t.string "template"
    t.bigint "sequence_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sequence_id"], name: "index_sequence_steps_on_sequence_id"
  end

  create_table "sequences", force: :cascade do |t|
    t.string "name"
    t.string "sender_email"
    t.string "sender_name"
    t.string "source"
    t.boolean "is_active"
    t.text "trigger_ads", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "sequence_type"
    t.text "description"
    t.string "marketing_type"
  end

  create_table "subscriber_sequences", force: :cascade do |t|
    t.bigint "sequence_id", null: false
    t.bigint "subscriber_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sequence_id"], name: "index_subscriber_sequences_on_sequence_id"
    t.index ["subscriber_id"], name: "index_subscriber_sequences_on_subscriber_id"
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
    t.integer "max_price"
    t.integer "min_surface"
    t.integer "min_rooms_number"
    t.integer "min_floor", default: 0
    t.integer "min_elevator_floor"
    t.bigint "broker_id"
    t.string "trello_id_card"
    t.string "status", default: "form_filled"
    t.string "project_type"
    t.boolean "has_messenger"
    t.text "specific_criteria"
    t.text "additional_question"
    t.string "initial_areas"
    t.index ["broker_id"], name: "index_subscribers_on_broker_id"
  end

  create_table "subways", force: :cascade do |t|
    t.string "name"
    t.string "line", default: "{}"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "favorites", "properties"
  add_foreign_key "favorites", "subscribers"
  add_foreign_key "properties", "areas"
  add_foreign_key "sequence_steps", "sequences"
  add_foreign_key "subscriber_sequences", "sequences"
  add_foreign_key "subscriber_sequences", "subscribers"
end
