namespace :scheduler do
  desc "charges accounts associated with recurring fees"
  task :recurring_fees => :environment do
    FeePlan.all.each do |p|
      p.apply_recurring_fees(ENV['INTERVAL'])
    end
  end
  
  desc "charges accounts associated with stripe transaction fees"
  task :stripe_fees => :environment do
    StripeFee.apply_stripe_transaction_fees(ENV['INTERVAL'])
  end
end