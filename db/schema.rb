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

ActiveRecord::Schema.define(version: 2020_03_12_071606) do

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

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  create_table "properties", force: :cascade do |t|
    t.integer "price"
    t.string "area"
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

  create_table "subscribers", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.string "phone"
    t.string "facebook_id"
    t.boolean "is_active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "max_price"
    t.integer "min_surface"
    t.integer "min_rooms_number"
    t.integer "min_floor", default: 0
    t.integer "min_elevator_floor"
  end

  add_foreign_key "favorites", "properties"
  add_foreign_key "favorites", "subscribers"
end
