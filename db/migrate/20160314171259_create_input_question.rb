class CreateInputQuestion < ActiveRecord::Migration
  def change
    create_table :input_questions do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
