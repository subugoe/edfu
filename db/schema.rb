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

ActiveRecord::Schema.define(version: 20150205110436) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "edfulogs", force: :cascade do |t|
    t.string "level"
    t.string "edfutype"
    t.string "text"
    t.string "column"
    t.text   "old"
    t.text   "new"
    t.string "uid"
  end

  add_index "edfulogs", ["uid"], name: "index_edfulogs_on_uid", using: :btree

  create_table "formulare", force: :cascade do |t|
    t.string "uid"
    t.text   "transliteration"
    t.text   "transliteration_nosuffix"
    t.text   "uebersetzung"
    t.string "texttyp"
    t.string "szeneID"
  end

  create_table "formulare_literaturen", id: false, force: :cascade do |t|
    t.integer "formular_id"
    t.integer "literatur_id"
  end

  add_index "formulare_literaturen", ["formular_id", "literatur_id"], name: "index_formulare_literaturen_on_formular_id_and_literatur_id", unique: true, using: :btree
  add_index "formulare_literaturen", ["formular_id"], name: "index_formulare_literaturen_on_formular_id", using: :btree
  add_index "formulare_literaturen", ["literatur_id", "formular_id"], name: "index_formulare_literaturen_on_literatur_id_and_formular_id", unique: true, using: :btree
  add_index "formulare_literaturen", ["literatur_id"], name: "index_formulare_literaturen_on_literatur_id", using: :btree

  create_table "formulare_photos", id: false, force: :cascade do |t|
    t.integer "formular_id"
    t.integer "photo_id"
  end

  add_index "formulare_photos", ["formular_id", "photo_id"], name: "index_formulare_photos_on_formular_id_and_photo_id", unique: true, using: :btree
  add_index "formulare_photos", ["formular_id"], name: "index_formulare_photos_on_formular_id", using: :btree
  add_index "formulare_photos", ["photo_id", "formular_id"], name: "index_formulare_photos_on_photo_id_and_formular_id", unique: true, using: :btree
  add_index "formulare_photos", ["photo_id"], name: "index_formulare_photos_on_photo_id", using: :btree

  create_table "goetter", force: :cascade do |t|
    t.string "uid"
    t.string "transliteration"
    t.string "ort"
    t.string "eponym"
    t.string "beziehung"
    t.string "funktion"
    t.string "anmerkung"
  end

  create_table "literaturen", force: :cascade do |t|
    t.string "beschreibung"
    t.string "detail"
  end

  add_index "literaturen", ["beschreibung", "detail"], name: "index_literaturen_on_beschreibung_and_detail", using: :btree

  create_table "orte", force: :cascade do |t|
    t.string "uid"
    t.string "transliteration"
    t.string "ort"
    t.string "lokalisation"
    t.string "anmerkung"
  end

  create_table "photos", force: :cascade do |t|
    t.string "name"
    t.string "typ"
    t.string "pfad"
    t.text   "kommentar"
  end

  add_index "photos", ["pfad"], name: "index_photos_on_pfad", using: :btree

  create_table "stellen", force: :cascade do |t|
    t.string  "tempel"
    t.string  "band"
    t.string  "bandseite"
    t.string  "bandseitezeile"
    t.string  "seite_start"
    t.string  "seite_stop"
    t.string  "zeile_start"
    t.string  "zeile_stop"
    t.string  "stelle_anmerkung"
    t.string  "stelle_unsicher"
    t.string  "zerstoerung"
    t.string  "freigegeben"
    t.integer "zugehoerigZu_id"
    t.string  "zugehoerigZu_type"
  end

  add_index "stellen", ["band"], name: "index_stellen_on_band", using: :btree
  add_index "stellen", ["seite_start"], name: "index_stellen_on_seite_start", using: :btree

  create_table "stellen_szenen", id: false, force: :cascade do |t|
    t.integer "stelle_id"
    t.integer "szene_id"
  end

  add_index "stellen_szenen", ["stelle_id", "szene_id"], name: "index_stellen_szenen_on_stelle_id_and_szene_id", unique: true, using: :btree
  add_index "stellen_szenen", ["stelle_id"], name: "index_stellen_szenen_on_stelle_id", using: :btree
  add_index "stellen_szenen", ["szene_id", "stelle_id"], name: "index_stellen_szenen_on_szene_id_and_stelle_id", unique: true, using: :btree
  add_index "stellen_szenen", ["szene_id"], name: "index_stellen_szenen_on_szene_id", using: :btree

  create_table "szenen", force: :cascade do |t|
    t.string "nummer"
    t.string "beschreibung"
    t.string "rect"
    t.string "polygon"
    t.string "koordinate_x"
    t.string "koordinate_y"
    t.string "blickwinkel"
    t.string "breite"
    t.string "prozent_z"
    t.string "hoehe"
    t.string "grau"
    t.string "name"
    t.string "dateiname"
    t.string "imagemap"
    t.string "bild_breite"
    t.string "bild_hoehe"
    t.string "offset_x"
    t.string "offset_y"
    t.string "breite_original"
    t.string "hoehe_original"
  end

  create_table "uploads", force: :cascade do |t|
    t.string "formular"
    t.string "ort"
    t.string "gott"
    t.string "wort"
    t.string "email"
  end

  create_table "users", force: :cascade do |t|
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
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "wbsberlin", force: :cascade do |t|
    t.string  "band"
    t.string  "seite_start"
    t.string  "seite_stop"
    t.string  "zeile_start"
    t.string  "zeile_stop"
    t.string  "notiz"
    t.integer "wort_id"
  end

  create_table "worte", force: :cascade do |t|
    t.string "uid"
    t.string "transliteration"
    t.string "transliteration_nosuffix"
    t.string "uebersetzung"
    t.string "hieroglyph"
    t.string "weiteres"
    t.string "belegstellenEdfu"
    t.string "belegstellenWb"
    t.string "anmerkung"
  end

end
