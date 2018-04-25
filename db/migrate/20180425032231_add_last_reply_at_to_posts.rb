class AddLastReplyAtToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :last_replied_at, :datetime
  end
  Post.all.each do |post|
    if post.comments.present?
      post.last_replied_at = post.comments.last.created_at
      post.save
    end
  end
end
