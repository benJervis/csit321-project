module UsersHelper
  def pad_number (num)
    return "" if num.blank? || num == 0

    if num.to_s.length == 9
      "0" + num.to_s
    else
      num.to_s
    end
  end

  def format_number (num)

    return "" if num.blank? || num == 0

    num = pad_number(num)
    if num.to_s.length == 8
      "#{num[0..3]} #{num[4..7]}"
    else
      if num[1].to_i == 4
        "#{num[0..3]} #{num[4..6]} #{num[7..9]}"
      else
        "(#{num[0..1]}) #{num[2..5]} #{num[6..9]}"
      end
    end
  end

  def number_link (num)
    return nil if num.blank? || num == 0
    link_to format_number(@user.phone_number), "tel:#{pad_number(@user.phone_number)}"
  end

  def user_levels
    %w(staff leader trusted member visitor)
  end

	def show_allowed(user, field)
		field_is_public = user.privacy_setting.send(field)

		current_user.is_staff? || field_is_public || current_user.id == user.id
	end

end
