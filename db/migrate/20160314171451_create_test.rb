class CreateTest < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string   "title"
      t.string   "test_code"
      t.integer  "duration"
    end
  end
end
