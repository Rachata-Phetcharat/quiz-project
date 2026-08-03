class AddRoleToCustomers < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:customers, :role)
      add_column :customers, :role, :string
    end
  end
end
