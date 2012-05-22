class CharacterMailer < ActionMailer::Base
  # include Resque::Mailer

  default from: "xiaohaoprog@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.character_mailer.new_record.subject
  #
  def new_record(char)
    @char = char

    mail to: "imwillmouse@gmail.com", subject: "Record a new Character!" do |format|
      format.html
    end
  end
end
