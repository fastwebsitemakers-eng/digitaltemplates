class CreatePurchases < ActiveRecord::Migration[8.1]
  def change
    create_table :purchases do |t|
      t.string :email, null: false
      t.string :product_name, null: false
      t.string :token, null: false
      t.string :stripe_session_id, null: false
      t.string :stripe_payment_intent_id
      t.integer :amount_paid, null: false
      t.string :currency, null: false, default: "usd"
      t.string :status, null: false, default: "paid"
      t.datetime :download_expires_at
      t.integer :download_count, null: false, default: 0
      t.timestamps
    end

    add_index :purchases, :token, unique: true
    add_index :purchases, :stripe_session_id, unique: true
    add_index :purchases, :email
  end
end
