# == Schema Information
#
# Table name: exchanges
#
#  id            :integer          not null, primary key
#  customer_id   :integer
#  worker_id     :integer
#  amount        :decimal(8, 2)    default(0.0)
#  created_at    :datetime
#  updated_at    :datetime
#  group_id      :integer
#  metadata_id   :integer
#  metadata_type :string(255)
#  deleted_at    :time
#  notes         :string(255)
#

class ExchangeDeleted < Exchange

end
