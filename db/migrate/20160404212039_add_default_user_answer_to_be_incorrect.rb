class AddDefaultUserAnswerToBeIncorrect < ActiveRecord::Migration
  def change
    change_column :user_answers, :correct, :boolean, :default => false
  end
end
