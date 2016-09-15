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
    { span_style: 'test' }
  end

  describe '#deliver' do
    it 'obfuscates auto links using options' do
      expect(email.delivery_method).to receive(:deliver!)
      email.deliver
      expect(email.body.decoded).to include('example<span style="test">.</span>com')
    end
  end

  describe '#deliver!' do
    it 'obfuscates auto links using options' do
      expect(email.delivery_method).to receive(:deliver!)
      email.deliver!
      expect(email.body.decoded).to include('example<span style="test">.</span>com')
    end
  end
end
