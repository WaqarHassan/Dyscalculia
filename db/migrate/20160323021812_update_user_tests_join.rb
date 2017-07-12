class UpdateUserTestsJoin < ActiveRecord::Migration
  def change
    change_table :user_tests do |t|
      t.belongs_to :user, index: true
      t.belongs_to :test, index: true
    end
  end
end
