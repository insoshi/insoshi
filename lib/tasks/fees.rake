namespace :fees do
  desc "charges accounts associated with recurring fees. expects interval 'month' or 'year'"
  task :recurring => :environment do
    FeePlan.enabled.each do |p|
      p.apply_recurring_fees(ENV['INTERVAL'])
    end
  end

  desc "accomodates heroku's daily scheduler. accounts are charged when end of month and/or end of year is detected"
  task :daily_check => :environment do
    FeePlan.daily_check_for_recurring_fees(Time.now)
  end
end
