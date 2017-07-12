class AddMaxTimeToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :max_time, :integer
  end
end
