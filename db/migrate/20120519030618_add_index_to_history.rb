class AddIndexToHistory < ActiveRecord::Migration
  def change
    add_index :histories, :character_id
  end
end
