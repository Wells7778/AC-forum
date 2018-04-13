class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.string   :title, null: false
      t.text     :content, null: false
      t.string   :image
      t.boolean  :public, null: false, default: true
      t.string   :authority, null: false, default: "all"
      t.integer  :user_id
      t.integer  :comments_count, default: 0
      t.integer  :viewed_count, default: 0

      t.timestamps
    end
  end
end
