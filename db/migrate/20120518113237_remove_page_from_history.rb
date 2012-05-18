class RemovePageFromHistory < ActiveRecord::Migration
  def change
    remove_column :histories, :page
  end
end
