class AdminMailer < ApplicationMailer
  def send_admin_password(admin_user, new_password)
    @new_password = new_password
    @admin_user = admin_user

    mail(to: admin_user.email, subject: "ListFixx administrator password")
  end

  def send_user_password(user, new_password)
    @new_password = new_password
    @user = user

    mail(to: user.email, subject: "ListFixx Password Reset")
  end

  def send_user_account_details(user, new_password)
    @new_password = new_password
    @user = user

    mail(to: user.email, subject: "New account created by administrator.")
  end
end
