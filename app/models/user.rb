class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def generate_api_key
    loop do
      token = Devise.friendly_token
      break token unless User.where(api_key: token).first
    end
  end
end
