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

ActiveRecord::Schema.define(version: 20141209145651) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "admin_users", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

  create_table "formulare", force: true do |t|
    t.string   "uid"
    t.string   "transliteration"
    t.string   "transliteration_nosuffix"
    t.string   "uebersetzung"
    t.string   "texttyp"
    t.string   "szeneID"
    t.string   "band"
    t.string   "seitezeile"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "formulare_literaturen", id: false, force: true do |t|
    t.integer  "formular_id"
    t.integer  "literatur_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "formulare_literaturen", ["formular_id", "literatur_id"], name: "index_formulare_literaturen_on_formular_id_and_literatur_id", unique: true
  add_index "formulare_literaturen", ["formular_id"], name: "index_formulare_literaturen_on_formular_id"
  add_index "formulare_literaturen", ["literatur_id", "formular_id"], name: "index_formulare_literaturen_on_literatur_id_and_formular_id", unique: true
  add_index "formulare_literaturen", ["literatur_id"], name: "index_formulare_literaturen_on_literatur_id"

  create_table "formulare_photos", id: false, force: true do |t|
    t.integer  "formular_id"
    t.integer  "photo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "formulare_photos", ["formular_id", "photo_id"], name: "index_formulare_photos_on_formular_id_and_photo_id", unique: true
  add_index "formulare_photos", ["formular_id"], name: "index_formulare_photos_on_formular_id"
  add_index "formulare_photos", ["photo_id", "formular_id"], name: "index_formulare_photos_on_photo_id_and_formular_id", unique: true
  add_index "formulare_photos", ["photo_id"], name: "index_formulare_photos_on_photo_id"

  create_table "goetter", force: true do |t|
    t.string   "uid"
    t.string   "transliteration"
    t.string   "ort"
    t.string   "eponym"
    t.string   "beziehung"
    t.string   "funktion"
    t.string   "band"
    t.string   "seitezeile"
    t.string   "anmerkung"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "literaturen", force: true do |t|
    t.string   "beschreibung"
    t.string   "detail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "literaturen", ["beschreibung", "detail"], name: "index_literaturen_on_beschreibung_and_detail"

  create_table "orte", force: true do |t|
    t.string   "uid"
    t.string   "transliteration"
    t.string   "ort"
    t.string   "lokalisation"
    t.string   "anmerkung"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", force: true do |t|
    t.string   "name"
    t.string   "typ"
    t.string   "pfad"
    t.text     "kommentar"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stellen", force: true do |t|
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
    t.string   "zerstoerung"
    t.string   "freigegeben"
    t.integer  "zugehoerigZu_id"
    t.string   "zugehoerigZu_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stellen", ["bandseitezeile"], name: "index_stellen_on_bandseitezeile"

  create_table "uploads", force: true do |t|
    t.string   "formular"
    t.string   "ort"
    t.string   "gott"
    t.string   "wort"
    t.string   "email"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "wbsberlin", force: true do |t|
    t.string   "band"
    t.string   "seite_start"
    t.string   "seite_stop"
    t.string   "zeile_start"
    t.string   "zeile_stop"
    t.string   "notiz"
    t.integer  "wort_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
