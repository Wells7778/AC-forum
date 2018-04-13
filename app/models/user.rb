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

  has_many :collections, dependent: :destroy
  has_many :collect_posts, through: :collections, source: :post

  has_many :friendships, -> {where status: true}, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :inverse_friendships, -> {where status: true}, class_name: "Friendship", foreign_key: "friend_id"
  has_many :inverse_friends, through: :inverse_friendships, source: :user
  has_many :not_yet_accepted_by_friendships, -> {where status: false}, class_name: "Friendship", dependent: :destroy
  has_many :not_yet_accepted_by_friends, through: :not_yet_accepted_by_friendships, source: :friend
  has_many :not_yet_responded_to_friendships, -> {where status: false}, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy
  has_many :not_yet_responded_to_friends, through: :not_yet_responded_to_friendships, source: :user

  mount_uploader :avatar, AvatarUploader

  before_create :generate_authentication_token

  ROLE = {
    normal: "一般用戶",
    admin: "管理者"
  }
  def admin?
    self.role == "admin"
  end

  def friend?(user)
    self.friends.include?(user) || self.inverse_friends.include?(user)
  end

  def not_yet_accepted_by?(user)
    self.not_yet_accepted_by_friends.include?(user)
  end

  def not_yet_responded_to?(user)
    self.not_yet_responded_to_friends.include?(user)
  end

  def all_friends
    friends = self.friends + self.inverse_friends
    return friends.uniq
  end

  def generate_authentication_token
     self.authentication_token = Devise.friendly_token
  end
end
