module ActivityLogger
  def add_activities(options = {})
    person = options[:person]
    include_person = options[:include_person]
    activity = options[:activity] ||
               Activity.create!(:item => options[:item], :person => person)
    person.contacts.each do |c|
      c.activities << activity unless c.activities.include?(activity)
    end
    if include_person
      person.activities << activity unless person.activities.include?(activity)
    end
  end
end