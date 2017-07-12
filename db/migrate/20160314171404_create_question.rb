class CreateQuestion < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string   "name"
      t.integer  "questionable_id"
      t.string   "questionable_type"
      t.datetime "created_at",        null: false
      t.datetime "updated_at",        null: false
      t.integer  "test_id"
    end
    add_index "questions", ["name"], name: "index_questions_on_name"
    add_index "questions", ["questionable_type", "questionable_id"], name: "index_questions_on_questionable_type_and_questionable_id"
    add_index "questions", ["test_id"], name: "index_questions_on_test_id"
  end
end
