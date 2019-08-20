class AdminMailer < Devise::Mailer
  default from: Rails.application.config.action_mailer.smtp_settings[:user_name]
  layout 'mailer'

  def test_sending_email(email)
    mail(to: email,
         body: "CHORDS portal, #{Profile.first.domain_name}, is testing email sending capability. If you received this email, your SMTP settings are correct!",
         content_type: 'text/html',
         subject: 'CHORDS Portal Email Test')
  end

  def send_registration_email(email, message)
    profile = Profile.first
    require 'socket'
    ip=Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
    admin_email = Rails.application.config.action_mailer.smtp_settings[:user_name] if Rails.application.config.action_mailer.smtp_settings


    body = <<-BODYSTRING
A new CHORDS portal has been created!

Portal Domain Name: #{profile.domain_name}
Portal Admin Email: #{admin_email}

Contact Name: #{profile.contact_name}
Contact Email: #{profile.contact_email}

Message from Site Admin:
#{message}


BODYSTRING

    mail(to: email,
         body: body,
         content_type: 'text/plain',
         subject: 'New CHORDS Portal Registered')
  end

  def new_user_waiting_for_approval(email)
    @email = email
    @domain = Profile.first.try(:domain_name)

    emails = User.with_role(:admin).map{|user| user.email}.join(',')

    mail(to: emails, subject: 'New User Awaiting Admin')
  end
end
