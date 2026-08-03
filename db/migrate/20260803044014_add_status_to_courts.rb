class AddStatusToCourts < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:courts, :status)
      add_column :courts, :status, :boolean
    end
  end
end
