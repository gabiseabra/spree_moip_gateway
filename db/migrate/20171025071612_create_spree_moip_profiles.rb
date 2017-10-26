class CreateSpreeMoipProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_moip_profiles, primary: :token do |t|
      t.integer :user_id
      t.string :token
      t.string :moip_id
      t.integer :payment_method_id
      t.string :payment_method_type
      t.integer :tax_document_type
      t.string :tax_document

      t.timestamps
    end
    add_index :spree_moip_profiles, :token, unique: true
    add_index :spree_moip_profiles, :user_id
  end
end
