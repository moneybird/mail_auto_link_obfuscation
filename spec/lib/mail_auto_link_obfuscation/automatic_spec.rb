# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'rails'

RSpec.describe MailAutoLinkObfuscation::Automatic do
  base_mailer = Class.new do
    def initialize(email = nil)
      @email = email
    end

    def mail(**_options)
      @email
    end
  end

  some_mailer = Class.new(base_mailer) do
    include MailAutoLinkObfuscation::Automatic
  end

  let(:email) { instance_double(Mail) }
  let(:options) { { foo: :bar } }
  let(:instance) { some_mailer.new(email) }

  describe '#mail' do
    before do
      allow(instance).to receive(:mail_auto_link_obfuscation_options).and_return(options)
    end

    it 'extends the email with ObfuscateAutoLinksOnDelivery' do
      email = instance.mail
      expect(email).to be_kind_of(MailAutoLinkObfuscation::ObfuscateAutoLinksOnDelivery)
    end

    it 'assigns mail_auto_link_obfuscation_options to the email' do
      email = instance.mail
      expect(email.mail_auto_link_obfuscation_options).to eq options
    end
  end

  describe '#mail_auto_link_obfuscation_options' do
    it 'assigns Rails mail autolink obfuscation config to the email' do
      allow(::Rails).to receive_message_chain(:application, :config, :mail_auto_link_obfuscation).and_return(options)
      expect(instance.mail_auto_link_obfuscation_options).to eq options
    end
  end
end
