class DeleteDefaultValues < ActiveRecord::Migration
  def change
    change_column_default(:users, :level_of_education, nil)
    change_column_default(:users, :employment_status, nil)
  end
end
