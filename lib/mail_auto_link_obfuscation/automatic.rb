# frozen_string_literal: true
module MailAutoLinkObfuscation
  module Automatic
    def mail(*args, &block)
      super.tap do |email|
        email.extend ObfuscateAutoLinksOnDelivery
        email.mail_auto_link_obfuscation_options = mail_auto_link_obfuscation_options.try(:dup)
      end
    end

    def mail_auto_link_obfuscation_options
      ::Rails.application.config.mail_auto_link_obfuscation
    end
  end
end
