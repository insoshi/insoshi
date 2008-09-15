# == Schema Information
# Schema version: 28
#
# Table name: conversations
#
#  id :integer(11)     not null, primary key
#

class Conversation < ActiveRecord::Base
  has_many :messages, :order => :created_at
end
