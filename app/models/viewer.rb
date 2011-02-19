class Viewer < ActiveRecord::Base
  belongs_to :topic
  belongs_to :person
end
