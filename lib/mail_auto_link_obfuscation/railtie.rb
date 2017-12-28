# frozen_string_literal: true

require 'rails'

module MailAutoLinkObfuscation
  class Railtie < ::Rails::Railtie
    config.mail_auto_link_obfuscation = {}
  end
end
