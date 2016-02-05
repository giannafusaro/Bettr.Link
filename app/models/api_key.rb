class ApiKey < ActiveRecord::Base
  attr_accessible :user, :token

  belongs_to :user

  before_create :generate_token

  private
    def generate_token
      loop do
        self.token = SecureRandom.hex.to_s
        break if self.class.exists?(token: token)
      end
    end
end
