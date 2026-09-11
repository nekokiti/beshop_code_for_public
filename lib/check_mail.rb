# frozen_string_literal: true
class CheckMail
  def self.check(email:)
    mail_regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
    email.match? mail_regex # =>true
  end
end
