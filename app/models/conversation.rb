# == Schema Information
# Schema version: 20080916002106
#
# Table name: conversations
#
#  id :integer(4)      not null, primary key
#

class Conversation < ActiveRecord::Base
  has_many :messages, :order => :created_at
end
