class GrowthMailer < ApplicationMailer

  default delivery_method: :smtp

  def new_growth_email(user, password)
    mail(to: "fred@hellodingdong.com", subject: "Coucou depuis le mailer Rails avec Gmail. Je crois que j'ai trouvé ce qu'il fallait pour envoyé depuis Gmail sans prise de tête :D ")
    mail.delivery_method.settings = {
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :user_name            => user,
      :password             => password,
      :authentication       => "plain",
      :domain               => 'gmail.com',
      :enable_starttls_auto => true
    }
  end


end
