class AddHistoriesCountToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :histories_count, :integer, default: 0
  end
end
