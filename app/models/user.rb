class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :posts, dependent: :destroy

  has_many :comments, dependent: :destroy
  has_many :commented_posts, through: :comments, source: :post

  has_many :vieweds, dependent: :destroy
  has_many :viewed_posts, through: :vieweds, source: :post

  mount_uploader :avatar, AvatarUploader

  def admin?
    self.role == "admin"
  end
end
