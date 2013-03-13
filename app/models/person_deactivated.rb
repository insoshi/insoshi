class PersonDeactivated < Person

  default_scope where(deactivated: true)

end