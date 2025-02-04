class CreateBlogs < ActiveRecord::Migration[5.2]
  def change
    create_table :blogs do |t|
      t.string :title
      t.string :hash_tag
      t.text :content
      t.json :photo
      t.references :category, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps
    end
    add_index :blogs, [:user_id, :created_at]

  end
end
