namespace :search do
  desc 'Report weekly activity'
  task weekly_report: :environment do
    # return unless Date.today.monday?
    reports = Report.where('created_at > ?', 7.days.ago)

    ReportingMailer.search(
      "Search Report - #{ 7.days.ago.to_date } - #{ Date.today }",
      reports
    )
  end
end
