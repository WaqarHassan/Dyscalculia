class CreateUserQuestions < ActiveRecord::Migration
  def change
    create_table :user_answers do |t|
      t.integer :time_taken
      t.text :answer_text
      t.boolean :correct
      t.belongs_to :user_test, index: true
      t.belongs_to :question, index: true
      t.timestamps null: false
    end
  end
end
