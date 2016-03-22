# == Schema Information
#
# Table name: conversations
#
#  id            :integer          not null, primary key
#  talkable_id   :integer
#  talkable_type :string(255)
#  exchange_id   :integer
#

class Conversation < ActiveRecord::Base
  has_many :messages, :order => :created_at

  # current now, only offer will be as this field
  # if you use other object stored as this(for example req), please update this comment
  belongs_to :talkable, polymorphic: true

  # only will be used for the payment of an offer
  # actually, this is a transact which is a subclass of exchange
  belongs_to :exchange


end
