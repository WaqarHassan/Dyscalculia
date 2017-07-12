class AddExtraTimeToUserAnswer < ActiveRecord::Migration
  def change
    add_column :user_answers, :extra_time, :integer, default: 0
  end
end
