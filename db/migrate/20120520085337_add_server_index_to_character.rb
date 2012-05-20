class AddServerIndexToCharacter < ActiveRecord::Migration
  def change
    add_index :characters, :server
  end
end
