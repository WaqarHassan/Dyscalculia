class AddLiveFieldToTests < ActiveRecord::Migration
  def change
    add_column :tests, :live, :boolean, default: false
  end
end
