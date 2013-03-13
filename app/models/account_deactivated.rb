class AccountDeactivated < Account

  default_scope joins(:person).where(people:{deactivated: true})

end