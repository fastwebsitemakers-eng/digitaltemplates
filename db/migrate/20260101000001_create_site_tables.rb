class CreateSiteTables < ActiveRecord::Migration[8.1]
  def change
    create_table :site_settings do |t|
      t.string :key, null: false, index: { unique: true }
      t.text :value
      t.timestamps
    end
    create_table :content_items do |t|
      t.string :kind, null: false, index: true
      t.string :title, null: false
      t.text :body
      t.integer :position, default: 0
      t.timestamps
    end
  end
end
