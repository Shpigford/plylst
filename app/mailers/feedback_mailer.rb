class FeedbackMailer < ApplicationMailer
  def feedback_email
    @message = params[:message]
    @user = params[:user]
    mail(to: ENV['feedback_email'], from: @user.email, subject: 'PLYLST Feedback')
  end
end
