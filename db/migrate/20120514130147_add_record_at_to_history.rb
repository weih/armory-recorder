class AddRecordAtToHistory < ActiveRecord::Migration
  def change
    add_column :histories, :record_at, :date

  end
end
