class AddLastUpdateToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :last_update, :date

  end
end
