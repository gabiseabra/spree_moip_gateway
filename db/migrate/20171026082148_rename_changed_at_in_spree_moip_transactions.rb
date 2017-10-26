class RenameChangedAtInSpreeMoipTransactions < ActiveRecord::Migration[5.1]
  def change
    rename_column :spree_moip_transactions, :changed_at, :moip_updated_at
  end
end
