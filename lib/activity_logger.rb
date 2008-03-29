module ActivityLogger
  def add_activities(item, person)
    activity = Activity.create!(:item => item, :person => person)
    person.activities << activity
    person.contacts.each { |c| c.activities << activity }
  end
end