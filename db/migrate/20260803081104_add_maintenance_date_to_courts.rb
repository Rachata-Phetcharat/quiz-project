class AddMaintenanceDateToCourts < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:courts, :maintenance_date)
      add_column :courts, :maintenance_date, :date
    end  
  end
end
