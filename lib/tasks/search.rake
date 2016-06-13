namespace :search do
  desc 'Report weekly activity'
  task weekly_report: :environment do
    return unless Date.today.monday?
    reports = Report.all.where('created_at > ?', 7.days_ago)
  end
end
