class CreateBookmarks < ActiveRecord::Migration[8.0]
  def change
    create_table :bookmarks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :url, null: false
      t.string :short_code, null: false
      t.boolean :is_public, default: false, null: false

      t.timestamps
    end
    add_index :bookmarks, :short_code, unique: true
  end
end
