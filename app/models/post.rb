class Post < ApplicationRecord
  belongs_to :user

  scope :open_public, -> { where(public: true) }
end
