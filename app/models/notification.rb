class Notification < ApplicationRecord
  has_and_belongs_to_many :users

	def read_by(user_id)
		self.update_attributes(read: true, read_time: Time.now, user_id: user_id)
	end

end
