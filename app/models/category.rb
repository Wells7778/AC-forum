class Category < ApplicationRecord
  validates_presence_of :name

  has_many :categories_posts, dependent: :restrict_with_error
  has_many :posts, through: :categories_posts
end
