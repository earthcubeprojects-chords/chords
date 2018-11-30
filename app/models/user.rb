class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  #######################################################################################
  # *** DO NOT *** change the order of this array as it is a bitmask, only add to the end
  #######################################################################################
  ROLES = %i[admin site_config measurements downloader registered_user guest]
  #######################################################################################

  before_create :set_default_roles
  after_create :send_admin_new_user_email

  # find users with a particular role
  # ex: User.with_role(:admin) => ActiveRecordRelation[user1, user2, ...]
  scope :with_role, -> (role) { where("roles_mask & #{2**ROLES.index(role)} > 0") }

  def roles=(roles)
    roles = [*roles].map { |r| r.to_sym }
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask.to_i || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def roles_pretty_printed
    my_roles = roles
    num_roles = my_roles.length
    temp = ""

    (0..(num_roles-1)).each do |i|
      temp += my_roles[i].to_s.humanize
      temp += ', ' unless num_roles == 1 || i == num_roles - 1
    end

    temp
  end

  def role?(role)
    roles.include?(role)
  end

  def self.generate_api_key
    loop do
      token = Devise.friendly_token
      break token unless User.where(api_key: token).first
    end
  end

private
  def set_default_roles
    if roles_mask.nil? && self.roles.blank?
      self.roles = [:guest]
    end
  end

  def send_admin_new_user_email
    AdminMailer.new_user_waiting_for_approval(email).deliver
  end
end
