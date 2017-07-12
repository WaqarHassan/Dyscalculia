class CreateAnswer < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.string  "answer_text"
      t.boolean "is_answer"
      t.integer "input_question_id"
      t.integer "multiple_choice_question_id"
    end
    add_index "answers", ["input_question_id"], name: "index_answers_on_input_question_id"
    add_index "answers", ["multiple_choice_question_id"], name: "index_answers_on_multiple_choice_question_id"
  end
end
