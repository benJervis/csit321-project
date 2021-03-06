class User < ApplicationRecord
	attr_accessor :remember_token, :activation_token, :reset_token, :old_password

	has_many :sent_messages, class_name: "Message", foreign_key: "sender_id"
	has_many :received_messages, class_name: "Message", foreign_key: "receiver_id"

	has_many :memberships, dependent: :destroy
	has_many :groups, -> { distinct }, through: :memberships
	has_and_belongs_to_many :contacts
	has_many :assignments, dependent: :destroy
	has_many :tasks, -> { distinct },	through: :assignments
	has_many :rosters, through: :tasks
	has_many :attendances, dependent: :destroy
	has_many :events, -> { distinct }, through: :attendances
	has_and_belongs_to_many :notifications
	has_one :privacy_setting, dependent: :destroy

	has_secure_password

	mount_uploader :image, ImageUploader

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates :first_name, 	presence: true, length: { maximum: 50 }
	validates :last_name, 	presence: true, length: { maximum: 50 }
	validates :email, 			presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	validate 	:level_must_be_valid
	validates :password, length: { minimum: 8 }, allow_nil: true

	before_save :check_level
	before_save :check_birthdate
	before_save { self.email = email.downcase }
	before_create :create_activation_digest
	after_create :create_privacy_setting

	def to_i
		self.id
	end

	def name
		"#{self.first_name} #{self.last_name}"
	end

	def staff?
		self.level == "staff"
	end

	def leader?
		self.level == "leader"
	end

	def trusted?
		self.level == "trusted"
	end

	def member?
		self.level == "member"
	end

	def visitor?
		self.level == "visitor"
	end

	def is_staff?
		%w(staff leader trusted).include?(self.level)
	end

	def admin_of
		self.memberships.select(&:trusted).collect(&:group_id)
	end

	def admin_of?(group)
		self.admin_of.include?(group.to_i)
	end

	def add_to(groups, opts = { trusted: false })
		groups = [groups] unless groups.is_a?(Array)
		groups.each do |group|
			self.memberships.create(group_id: group.to_i, trusted: opts[:trusted])
		end
	end

	def remove_from(groups)
		groups = [groups] unless groups.is_a?(Array)
		groups.each do |group|
			self.memberships.select{ |mem| mem.group_id ==  group.to_i }.first.destroy
		end
	end

	def make_admin(group)
		self.memberships.select{ |mem| mem.group_id == group.to_i }.first.update_attributes(trusted: true)
	end

	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	def authenticated?(attribute, token)
		digest = send("#{attribute}_digest")
		return false if digest.nil?
		BCrypt::Password.new(digest).is_password?(token)
	end

	def forget
		update_attribute(:remember_digest, nil)
	end

	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	def User.new_token
		SecureRandom.urlsafe_base64
	end

	def activate
		self.update_attribute(:activated, true)
		self.update_attribute(:activated_at, Time.zone.now)
	end

	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	def create_reset_digest
		self.reset_token = User.new_token
		update_attribute(:reset_digest, User.digest(reset_token))
		update_attribute(:reset_sent_at, Time.zone.now)
	end

	def send_password_reset_email
		UserMailer.password_reset(self).deliver_now
	end

	def send_password_update_email
		UserMailer.password_notification(self).deliver_now
	end

	def send_account_setup_email
		UserMailer.account_setup(self).deliver_now
	end

	def password_reset_expired?
		reset_sent_at < 2.hours.ago
	end

	private
		def check_level
			self.level.downcase!
		end

		def check_birthdate
		end

		def level_must_be_valid
			if self.level.nil?
				errors.add(:level, "can't be blank")
			elsif !(%w(staff leader trusted member visitor).include?(self.level.downcase))
				errors.add(:level, "must be one of [staff, leader, trusted, member, visitor]")
			end
		end

		def create_activation_digest
			self.activation_token = User.new_token
			self.activation_digest = User.digest(activation_token)
		end
end
