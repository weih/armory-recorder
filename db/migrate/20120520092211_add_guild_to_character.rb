class AddGuildToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :guild, :string

  end
end
