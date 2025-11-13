class CreateGalleries < ActiveRecord::Migration[8.0]
  def change
    create_table :galleries do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :is_public, default: false, null: false
      t.string :short_code, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :cover_photo_id

      t.timestamps
    end
    add_index :galleries, :short_code, unique: true
  end
end
