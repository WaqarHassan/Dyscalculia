class AddStatusToUserAnswers < ActiveRecord::Migration
  def change
    add_column :user_answers, :status, :integer, default: 0
  end
end
