# frozen_string_literal: true

require 'spec_helper'
require 'mail'

RSpec.describe MailAutoLinkObfuscation::ObfuscateAutoLinksOnDelivery do
  let(:email) do
    Mail.new(body: 'foobar example.com', content_type: 'text/html').tap do |email|
      email.extend described_class
      email.mail_auto_link_obfuscation_options = options
    end
  end

  let(:options) do
  end

  describe '#deliver' do
    it 'obfuscates auto links using options' do
      allow(email.delivery_method).to receive(:deliver!)
      email.deliver
      expect(email.delivery_method).to have_received(:deliver!)
    end
  end

  describe '#deliver!' do
    it 'obfuscates auto links using options' do
      allow(email.delivery_method).to receive(:deliver!)
      email.deliver!
      expect(email.delivery_method).to have_received(:deliver!)
    end
  end
end
