class Post < ApplicationRecord
  belongs_to :user

  has_many :categories_posts
  has_many :categories, through: :categories_posts

  has_many :comments, dependent: :destroy
  has_many :commented_users, through: :comments, source: :user

  scope :open_public, -> { where(public: true) }

  def self.readable_posts(user)
    Post.where(authority: "all").or(where(authority: "myself", user: user))
  end
end
