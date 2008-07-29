module ActivityLogger

  # Add an activity to the feeds of a person's contacts.
  # Usually, we only add to the feeds of the contacts, not the person himself.
  # For example, if a person makes a forum post, the activity shows up in
  # his contacts' feeds but not his.
  # The :include_person option is to handle the case when add_activities
  # should include the person as well.  This happens when
  # someone comments on a person's blog post or wall.  In that case, when
  # adding activities to the contacts of the wall's or post's owner,
  # we should include the owner as well, so that he sees in his feed
  # that a comment has been made.
  def add_activities(options = {})
    person = options[:person]
    include_person = options[:include_person]
    activity = options[:activity] ||
               Activity.create!(:item => options[:item], :person => person)
    all_ids = person.contacts.map(&:id)
    invalid_ids =  Feed.find(:all, :select => "DISTINCT person_id",
                      :conditions => ["person_id IN (?) and activity_id = ?",
                                       all_ids, activity]).map(&:person_id)
    valid_ids = all_ids - invalid_ids
    values = [valid_ids, [activity.id] * valid_ids.length].transpose
    values = values.inspect[1...-1].gsub('[', '(').gsub(']', ')')
    unless valid_ids.empty?
      ActiveRecord::Base.connection.execute("INSERT INTO feeds (person_id, activity_id) VALUES #{values}")
    end
    # person.contacts.each do |c|
    #   # Prevent duplicate entries in the feed.
    #   c.activities << activity unless c.activities.include?(activity)
    # end
    if include_person
      person.activities << activity unless person.activities.include?(activity)
    end
  end
end