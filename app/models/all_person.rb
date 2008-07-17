class AllPerson < Person
  is_indexed :fields => [ 'name', 'description' ]
end