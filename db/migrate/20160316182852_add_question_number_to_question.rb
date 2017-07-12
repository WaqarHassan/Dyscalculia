class AddQuestionNumberToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :question_no, :integer
  end
end
