class Comment < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :post, counter_cache: true
  after_save :update_post_last_replied_at
  validates_presence_of :content

  def update_post_last_replied_at
    self.post.update(last_replied_at: self.updated_at)
  end
end
