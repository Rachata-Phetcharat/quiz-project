class AddBalanceToCustomers < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:customers, :balance)
      add_column :customers, :balance, :decimal
    end
  end
end
