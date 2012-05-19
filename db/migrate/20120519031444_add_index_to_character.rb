class AddIndexToCharacter < ActiveRecord::Migration
  def change
    add_index :characters, [:name, :server]
  end
end
