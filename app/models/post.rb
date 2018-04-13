class Post < ApplicationRecord
  belongs_to :user

  has_many :categories_posts
  has_many :categories, through: :categories_posts

  has_many :comments, dependent: :destroy
  has_many :commented_users, through: :comments, source: :user

  has_many :vieweds, dependent: :destroy
  has_many :viewed_users, through: :vieweds, source: :user

  mount_uploader :image, ImageUploader

  scope :open_public, -> { where(public: true) }

  def self.readable_posts(user)
    Post.where(authority: "all").or(where(authority: "myself", user: user))
  end

  def viewed_by?(user)
    self.viewed_users.include?(user)
  end
end
