module ActivityLogger
  def add_activities(options = {})
    person = options[:person]
    activity = options[:activity] ||
               Activity.create!(:item => options[:item], :person => person)
    person.contacts.each { |c| c.activities << activity }
  end
end