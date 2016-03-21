# == Schema Information
#
# Table name: form_signup_fields
#
#  id         :integer          not null, primary key
#  key        :string(255)
#  title      :string(255)
#  mandatory  :boolean          default(FALSE)
#  field_type :string(255)
#  order      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  options    :string(255)
#

require 'test_helper'

class FormSignupFieldTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
