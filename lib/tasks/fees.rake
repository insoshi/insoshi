namespace :fees do
  desc "accomodates heroku's daily scheduler. accounts are charged on the monthly or yearly anniversary of their fees as appropriate"
  task :daily_check => :environment do
    FeePlan.daily_check_for_recurring_fees(Time.now)
  end
end
