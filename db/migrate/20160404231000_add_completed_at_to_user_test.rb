class AddCompletedAtToUserTest < ActiveRecord::Migration
  def change
    add_column :user_tests, :completed_at, :datetime
  end
end
