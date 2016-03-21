# == Schema Information
#
# Table name: time_zones
#
#  id         :integer          not null, primary key
#  time_zone  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  date_style :string(255)      default("mm/dd/yy")
#


class TimeZone < ActiveRecord::Base

  Date_Style = {'mm/dd/yy' => '%m/%d/%y %H:%M', 'dd/mm/yy' => '%d/%m/%y %H:%M'}

end
