class CreateEquations < ActiveRecord::Migration
  def change
    create_table :equations do |t|
      t.string :text
      t.belongs_to :question, index: true
    end
  end
end
