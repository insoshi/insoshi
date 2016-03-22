# == Schema Information
#
# Table name: accounts
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  balance         :decimal(8, 2)    default(0.0)
#  person_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  group_id        :integer
#  credit_limit    :decimal(8, 2)
#  offset          :decimal(8, 2)    default(0.0)
#  paid            :decimal(8, 2)    default(0.0)
#  earned          :decimal(8, 2)    default(0.0)
#  reserve_percent :decimal(8, 7)    default(0.0)
#  reserve         :boolean          default(FALSE)
#  rollover_charge :decimal(, )      default(0.0)
#

class AccountDeactivated < Account

end
