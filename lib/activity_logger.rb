module ActivityLogger

  # Add an activity to the feeds of a person's contacts.
  # Usually, we only add to the feeds of the contacts, not the person himself.
  # For example, if a person makes a forum post, the activity shows up in
  # his contacts' feeds but not his.
  # The :include_person option is to handle the case when add_activities
  # should include the person as well.  This happens when
  # someone comments on a person's blog post or wall.  In that case, when
  # adding activities to the contacts of the wall's or post's owner,
  # we should include the owner as well, so that he see's in his feed
  # that a comment has been made.
  def add_activities(options = {})
    person = options[:person]
    include_person = options[:include_person]
    activity = options[:activity] ||
               Activity.create!(:item => options[:item], :person => person)
    person.contacts.each do |c|
      c.activities << activity #unless c.activities.include?(activity)
    end
    if include_person
      person.activities << activity #unless person.activities.include?(activity)
    end
  end
end