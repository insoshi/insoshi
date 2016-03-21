# == Schema Information
#
# Table name: capabilities
#
#  id             :integer          not null, primary key
#  group_id       :integer
#  oauth_token_id :integer
#  scope          :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  invalidated_at :datetime
#

require 'spec_helper'

describe Capability do
  pending "add some examples to (or delete) #{__FILE__}"
end
