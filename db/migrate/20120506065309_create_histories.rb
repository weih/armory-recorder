class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.string :target_page
      t.integer :character_id

      t.timestamps
    end
  end
end
