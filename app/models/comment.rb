class Comment < ActiveRecord::Base
  validates_presence_of :body
  validates_length_of :body, :maximum => MAX_TEXT_LENGTH
end
