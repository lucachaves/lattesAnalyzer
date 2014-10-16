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

ActiveRecord::Schema.define(version: 20141016090936) do

  create_table "courses", force: true do |t|
    t.string   "name"
    t.integer  "university_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courses", ["university_id"], name: "index_courses_on_university_id"

  create_table "degrees", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.integer  "year"
    t.integer  "course_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "degrees", ["course_id"], name: "index_degrees_on_course_id"
  add_index "degrees", ["person_id"], name: "index_degrees_on_person_id"

  create_table "locations", force: true do |t|
    t.string   "city"
    t.string   "uf"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", force: true do |t|
    t.string   "name"
    t.date     "updated"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["location_id"], name: "index_people_on_location_id"

  create_table "universities", force: true do |t|
    t.string   "name"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "universities", ["location_id"], name: "index_universities_on_location_id"

end
