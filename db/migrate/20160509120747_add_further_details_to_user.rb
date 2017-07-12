class AddFurtherDetailsToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :diagnosis, default: 0
      t.integer :gender, default: 0
      t.integer :employment_status, default: 0
    end

  end
end
