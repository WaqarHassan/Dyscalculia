class ChangeTypeOfUserColumns < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.change :level_of_education, :string, default: "None"
      t.change :diagnosis, :string, default: "None"
      t.change :employment_status, :string, default: "Unemployed"
    end
  end
end
