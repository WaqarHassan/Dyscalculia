class CreateUserTests < ActiveRecord::Migration
  def change
    create_table :user_tests do |t|
      t.datetime :started_at
      t.datetime :deadline_at

      t.timestamps null: false
    end
  end
end
