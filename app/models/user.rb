class User < ActiveRecord::Base
  has_secure_password
  has_many :links

  validates :name, :email, :password, presence: true
  validates :email, presence: true, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
    message: 'is invalid'
  }
  validates :email, uniqueness: true
end
