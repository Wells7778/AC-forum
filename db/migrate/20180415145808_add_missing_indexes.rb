class AddMissingIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index :categories_posts, :category_id
    add_index :categories_posts, :post_id
    add_index :collections, :post_id
    add_index :collections, :user_id
    add_index :collections, [:post_id, :user_id]
    add_index :comments, :post_id
    add_index :comments, :user_id
    add_index :comments, [:post_id, :user_id]
    add_index :friendships, :friend_id
    add_index :friendships, :user_id
    add_index :friendships, [:friend_id, :friend_id]
    add_index :friendships, [:user_id, :user_id]
    add_index :posts, :user_id
    add_index :vieweds, :post_id
    add_index :vieweds, :user_id
    add_index :vieweds, [:post_id, :user_id]
  end
end
