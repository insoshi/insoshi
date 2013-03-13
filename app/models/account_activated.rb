class AccountActivated < Account

  default_scope joins(:person).where(people:{deactivated: false})

end