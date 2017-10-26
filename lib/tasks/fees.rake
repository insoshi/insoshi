namespace :fees do
  desc "accomodates heroku's daily scheduler. accounts are charged on the monthly or yearly anniversary of their fees as appropriate"
  task :daily_check => :environment do
    begin
      FeePlan.daily_check_for_recurring_fees(Time.now)

      if Date.today == Date.today.end_of_week
        StripeFee.apply_stripe_transaction_fees('week')
      end

    rescue
      ExceptionNotifier.notify_exception(e)
    end
  end
end
