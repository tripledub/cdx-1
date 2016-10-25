class ApplicationMailer < ActionMailer::Base
  helper :mailer

  default from: ENV['MAILER_SENDER'] || 'admin@thecdx.org'
  layout 'mailer'
end
