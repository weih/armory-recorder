class AddThumbnailToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :thumbnail, :string

  end
end
