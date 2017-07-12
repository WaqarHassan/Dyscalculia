class AddFieldsToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.date :date_of_birth
      t.string :postcode
      t.integer :level_of_education, default: 0
    end

  end
end
