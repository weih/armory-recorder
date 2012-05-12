class AddLevelToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :level, :integer, default: 1
    add_column :characters, :leveling, :boolean, default: true
    add_column :characters, :achievements, :integer, default: 0

  end
end
