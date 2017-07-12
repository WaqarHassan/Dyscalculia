class CreateMultipleChoiceQuestion < ActiveRecord::Migration
  def change
    create_table :multiple_choice_questions do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
