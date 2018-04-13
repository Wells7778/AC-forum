class Post < ApplicationRecord
  belongs_to :user

  scope :open_public, -> { where(public: true) }

  def self.readable_posts(user)
    Post.where(authority: "Friend", user: user.all_friends).or( where(authority: "All")).or(where(authority: "Myself", user: user))
  end
end
