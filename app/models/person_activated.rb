class PersonActivated < Person
  default_scope where(deactivated: false)
end