class CreateVideos < ActiveRecord::Migration[8.0]
  def change
    create_table :videos do |t|
      t.references :user, null: false, foreign_key: true
      t.references :album, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :short_code, null: false
      t.boolean :is_public, default: false
      t.string :status, default: "processing"
      t.integer :duration_seconds
      t.integer :width
      t.integer :height
      t.integer :file_size_bytes

      t.timestamps
    end

    add_index :videos, :short_code, unique: true
  end
end
