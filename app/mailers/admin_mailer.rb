class AdminMailer < Devise::Mailer
  default from: 'admin@chordsrt.com'
  layout 'mailer'

  def test_sending_email(email)
    mail(to: email,
         body: "CHORDS portal, #{Profile.first.domain_name}, is testing email sending capability. If you received this email, your SMTP settings are correct!",
         content_type: 'text/html',
         subject: 'CHORDS Portal Email Test')
  end

  def new_user_waiting_for_approval(email)
    @email = email
    @domain = Profile.first.try(:domain_name)

    emails = User.with_role(:admin).map{|user| user.email}.join(',')

    mail(to: emails, subject: 'New User Awaiting Admin')
  end
end
