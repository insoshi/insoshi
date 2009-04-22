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
    
    people_ids = people_to_add(person, activity, include_person)
    do_feed_insert(people_ids, activity.id) unless people_ids.empty?
  end
  
  private
  
    # Return the ids of the people whose feeds need to be updated.
    # The key step is the subtraction of people who already have the activity.
    def people_to_add(person, activity, include_person)
      all = person.contacts.map(&:id)
      all.push(person.id) if include_person
      all - already_have_activity(all, activity)
    end
  
    # Return the ids of people who already have the given feed activity.
    # The results of the query are Feed objects with only a person_id
    # attribute (due to the "DISTINCT person_id" clause), which we extract
    # using map(&:person_id).
    def already_have_activity(people, activity)
      Feed.find(:all, :select => "DISTINCT person_id",
                      :conditions => ["person_id IN (?) AND activity_id = ?",
                                      people, activity]).map(&:person_id)    
    end
  
    # Return the SQL values string needed for the SQL VALUES clause.
    # Arguments: an array of ids and a common value to be inserted for each.
    # E.g., values([1, 3, 4], 17) returns "(1, 17), (3, 17), (4, 17)"
    def values(ids, common_value)
      common_values = [common_value] * ids.length
      convert_to_sql(ids.zip(common_values))
    end

    # Convert an array of values into an SQL string.
    # For example, [[1, 2], [3, 4]] becomes "(1,2), (3, 4)".
    # This does no escaping since it currently only needs to work with ints.
    def convert_to_sql(array_of_values)
      array_of_values.inspect[1...-1].gsub('[', '(').gsub(']', ')')
    end
  
    def do_feed_insert(people_ids, activity_id)
      sql = %(INSERT INTO feeds (person_id, activity_id) 
              VALUES #{values(people_ids, activity_id)})
      ActiveRecord::Base.connection.execute(sql)
    end
end