class AddLastReplyAtToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :last_replied_at, :datetime
  end
end
