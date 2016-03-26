# == Schema Information
#
# Table name: account_imports
#
#  id         :integer          not null, primary key
#  person_id  :integer          not null
#  file       :string(255)
#  successful :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe AccountImport do
  pending "add some examples to (or delete) #{__FILE__}"
end
