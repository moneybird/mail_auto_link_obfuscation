# frozen_string_literal: true
module MailAutoLinkObfuscation
  module ObfuscateAutoLinksOnDelivery
    attr_accessor :mail_auto_link_obfuscation_options

    def deliver
      obfuscate_links
      super
    end

    def deliver!
      obfuscate_links
      super
    end

    private

    def obfuscate_links
      AutoLinkObfuscator.new(self, mail_auto_link_obfuscation_options).run
    end
  end
end
