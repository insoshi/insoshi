namespace :scheduler do
  desc "charges accounts associated with recurring fees"
  task :recurring_fees => :environment do
    case Date.today
    when Date.today.end_of_month  
      FeePlan.all.each do |p|
        p.apply_recurring_fees('month')
      end
    when Date.today.end_of_year
      FeePlan.all.each do |p|
        p.apply_recurring_fees('year')
      end
    end
  end
  
  desc "charges accounts associated with stripe transaction fees"
  task :stripe_fees => :environment do
    if Date.today == Date.today.end_of_month
      StripeFee.apply_stripe_transaction_fees('month')
    end
  end
end