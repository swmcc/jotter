class CreatePhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :photos do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :is_public, default: false, null: false
      t.string :short_code, null: false
      t.references :user, null: false, foreign_key: true
      t.references :album, null: true, foreign_key: true

      t.timestamps
    end
    add_index :photos, :short_code, unique: true
  end
end
