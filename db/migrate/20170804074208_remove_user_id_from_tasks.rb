class RemoveUserIdFromTasks < ActiveRecord::Migration[5.0]
  def change
		change_table :tasks do |t|
			t.remove :user_id
		end
  end
end
