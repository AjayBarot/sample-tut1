class User < ActiveRecord::Base
mount_uploader :image, ImageUploader
validates :name, presence: true, length: {maximum: 50}
#VALID_EMAIL_REGEX = /\A[\W+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
validates :email, presence: true, uniqueness: { case_sensitive: false }
has_many :microposts, dependent: :destroy
has_many :relationships, foreign_key: "follower_id", dependent: :destroy
has_many :followed_users, through: :relationships, source: :followed
has_many :reverse_relationships, foreign_key: "followed_id", class_name:  "Relationship", dependent:   :destroy
has_many :followers, through: :reverse_relationships, source: :follower
has_secure_password
validates :password, length: { minimum: 6 }
before_save { self.email = email.downcase }
before_create :create_remember_token
def User.new_remember_token
	SecureRandom.urlsafe_base64
end

def self.from_users_followed_by(user)
    followed_user_ids = user.followed_user_ids
    where("user_id IN (:followed_user_ids) OR user_id = :user_id",
          followed_user_ids: followed_user_ids, user_id: user)
end

def feed
	Micropost.from_users_followed_by(self)	
end

def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

def User.encrypt(token)
	Digest::SHA1.hexdigest(token.to_s)
end

def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end

def feed
	Micropost.where("user_id = ?", id)
end

private 
	def create_remember_token
		self.remember_token = User.encrypt(User.new_remember_token)
	end
end
