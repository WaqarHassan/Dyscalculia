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

ActiveRecord::Schema.define(version: 20160511112205) do

  create_table "answers", force: :cascade do |t|
    t.string  "answer_text",                 limit: 255
    t.boolean "is_answer"
    t.integer "input_question_id",           limit: 4
    t.integer "multiple_choice_question_id", limit: 4
  end

  add_index "answers", ["input_question_id"], name: "index_answers_on_input_question_id", using: :btree
  add_index "answers", ["multiple_choice_question_id"], name: "index_answers_on_multiple_choice_question_id", using: :btree

  create_table "equations", force: :cascade do |t|
    t.string  "text",        limit: 255
    t.integer "question_id", limit: 4
  end

  add_index "equations", ["question_id"], name: "index_equations_on_question_id", using: :btree

  create_table "input_questions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "multiple_choice_questions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.integer  "questionable_id",      limit: 4
    t.string   "questionable_type",    limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "test_id",              limit: 4
    t.integer  "question_no",          limit: 4
    t.string   "picture",              limit: 255
    t.string   "curriculum_reference", limit: 255
    t.string   "reading",              limit: 255
    t.integer  "max_time",             limit: 4
  end

  add_index "questions", ["name"], name: "index_questions_on_name", using: :btree
  add_index "questions", ["questionable_type", "questionable_id"], name: "index_questions_on_questionable_type_and_questionable_id", using: :btree
  add_index "questions", ["test_id"], name: "index_questions_on_test_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tests", force: :cascade do |t|
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "title",      limit: 255
    t.string   "test_code",  limit: 255
    t.integer  "duration",   limit: 4
    t.boolean  "live",                   default: false
  end

  create_table "user_answers", force: :cascade do |t|
    t.integer  "time_taken",   limit: 4,     default: 0
    t.text     "answer_text",  limit: 65535
    t.boolean  "correct",                    default: false
    t.integer  "user_test_id", limit: 4
    t.integer  "question_id",  limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "status",       limit: 4,     default: 0
    t.integer  "extra_time",   limit: 4,     default: 0
  end

  add_index "user_answers", ["question_id"], name: "index_user_answers_on_question_id", using: :btree
  add_index "user_answers", ["user_test_id"], name: "index_user_answers_on_user_test_id", using: :btree

  create_table "user_tests", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "deadline_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id",      limit: 4
    t.integer  "test_id",      limit: 4
    t.datetime "completed_at"
  end

  add_index "user_tests", ["test_id"], name: "index_user_tests_on_test_id", using: :btree
  add_index "user_tests", ["user_id"], name: "index_user_tests_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.date     "date_of_birth"
    t.string   "postcode",               limit: 255
    t.string   "level_of_education",     limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.boolean  "admin",                              default: false
    t.string   "diagnosis",              limit: 255, default: "0"
    t.integer  "gender",                 limit: 4,   default: 0
    t.string   "employment_status",      limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
