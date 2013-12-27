# == Schema Information
# Schema version: 20090216032013
#
# Table name: conversations
#
#  id :integer(4)      not null, primary key
#

class Conversation < ActiveRecord::Base
  has_many :messages, :order => :created_at

  belongs_to :talkable, polymorphic: true
end
