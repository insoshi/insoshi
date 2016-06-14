class ReportingMailer < ActionMailer::Base
  default from: 'no-reply@vbsrmarket.com'
  REPORTING_ADDRESS = ENV.fetch('REPORTING_ADDRESS')

  # Dispatches the search report to the reproting email
  def search(title, reports)
    @reports = reports

    mail(
      to: REPORTING_ADDRESS,
      subject: title
    )
  end
end
