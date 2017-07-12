class AddDefaultTimeToTimeTakenInQuestion < ActiveRecord::Migration
  def change
    change_column :user_answers, :time_taken, :integer, :default => 0
  end
end
