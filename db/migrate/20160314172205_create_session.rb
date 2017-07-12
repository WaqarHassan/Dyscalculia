class CreateSession < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string   "session_id", null: false
      t.text     "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
