class AddRaceAndKlassToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :race, :string
    add_column :characters, :klass, :string
    add_column :characters, :klass_color, :string
  end
end
