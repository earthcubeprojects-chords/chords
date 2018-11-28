class AdminMailer < Devise::Mailer
  default from: 'admin@chordsrt.com'
  layout 'mailer'

  def new_user_waiting_for_approval(email)
    @email = email
    @domain = Profile.first.domain_name

    emails = User.with_role(:admin).map{|user| user.email}.join(',')

    mail(to: emails, subject: 'New User Awaiting Admin')
  end
end
