class ApplicationMailer < ActionMailer::Base
  # Default to Mailjet pilot email, but allow overriding in production
  default from: ENV.fetch("MAILER_SENDER", "pilot@mailjet.com")
  layout "mailer"
end
