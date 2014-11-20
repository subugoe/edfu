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

ActiveRecord::Schema.define(version: 20141120161729) do

  create_table "formulare", force: true do |t|
    t.string   "uid"
    t.string   "transliteration"
    t.string   "transliteration_nosuffix"
    t.string   "uebersetzung"
    t.string   "texttyp"
    t.string   "photo"
    t.string   "photo_pfad"
    t.string   "photo_kommentar"
    t.string   "szeneID"
    t.string   "literatur"
    t.string   "band"
    t.string   "seitenzeile"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "goetter", force: true do |t|
    t.string   "uid"
    t.string   "transliteration"
    t.string   "transliteration_nosuffix"
    t.string   "ort"
    t.string   "eponym"
    t.string   "beziehung"
    t.string   "funktion"
    t.string   "band"
    t.string   "seitenzeile"
    t.string   "anmerkung"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orte", force: true do |t|
    t.string   "uid"
    t.string   "stelle"
    t.string   "transliteration"
    t.string   "transliteration_nosuffix"
    t.string   "ort"
    t.string   "lokalisation"
    t.string   "anmerkung"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stellen", force: true do |t|
    t.string   "uid"
    t.string   "tempel"
    t.string   "band"
    t.string   "bandseite"
    t.string   "bandseitezeile"
    t.string   "seite_start"
    t.string   "seite_stop"
    t.string   "zeile_start"
    t.string   "zeile_stop"
    t.string   "stelle_anmerkung"
    t.string   "stelle_unsicher"
    t.string   "start"
    t.string   "stop"
    t.string   "zerstoerung"
    t.string   "freigegeben"
    t.integer  "zugehoerigZu_id"
    t.string   "zugehoerigZu_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uploads", force: true do |t|
    t.string   "formular"
    t.string   "ort"
    t.string   "gott"
    t.string   "wort"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wb_berlins", force: true do |t|
    t.string   "uid"
    t.string   "band"
    t.string   "seite_start"
    t.string   "seite_stop"
    t.string   "zeile_start"
    t.string   "zeile_stop"
    t.integer  "wort_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wb_berlins", ["wort_id"], name: "index_wb_berlins_on_wort_id"

  create_table "worte", force: true do |t|
    t.string   "uid"
    t.string   "transliteration"
    t.string   "transliteration_nosuffix"
    t.string   "uebersetzung"
    t.string   "hieroglyph"
    t.string   "weiteres"
    t.string   "belegstellenEdfu"
    t.string   "belegstellenWb"
    t.string   "anmerkung"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
