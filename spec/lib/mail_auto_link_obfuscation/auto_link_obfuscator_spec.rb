# frozen_string_literal: true

require 'spec_helper'
require 'mail'

RSpec.describe MailAutoLinkObfuscation::AutoLinkObfuscator do
  let(:obfuscator) { described_class.new(mail, options) }
  let(:options) { nil }

  let(:linkables) do
    [
      'https://hacker.com',
      'example.com',
      'a.b.c.domain.com',
      'http://localhost',
      'www.a-b.nl',
      'ftp://123.234.123.234',
      'foo@bar.nl',
      '//2130706433/example' # DWORD IP
    ]
  end

  let(:unlinkables) do
    [
      'foobar',
      'foo. bar',
      'a.b.c. solutions b.v.',
      'a.th.b foobar'
    ]
  end

  let(:content) { (linkables + unlinkables).join(' ') }

  let(:body) { mail.body.decoded }
  let(:body_printable) { body.delete("\u200C") }

  let(:text_part) { mail.text_part.body.decoded }
  let(:text_part_printable) { text_part.delete("\u200C") }

  let(:html_part) { mail.html_part.body.decoded }
  let(:html_part_printable) { html_part.delete("\u200C") }

  context 'when mail has text body' do
    let(:mail) do
      Mail.new(body: content, content_type: 'text/plain; charset=UTF-8')
    end

    it 'obfuscates linkables' do
      obfuscator.run
      expect(body).not_to include(*linkables)
      expect(body_printable).to include(*linkables)
    end

    it 'obfuscates using zero-width non-joiner chars around key chars' do
      obfuscator.run
      expect(body).to include("https\u200C://\u200Chacker\u200C.\u200Ccom")
      expect(body).to include("foo\u200C@\u200Cbar\u200C.\u200Cnl")
    end

    it 'does not change unlinkables' do
      obfuscator.run
      expect(body).to include(*unlinkables)
    end
  end

  context 'when mail has html body' do
    let(:mail) do
      Mail.new(body: content, content_type: 'text/html; charset=UTF-8')
    end

    it 'obfuscates linkables' do
      obfuscator.run
      expect(body).not_to include(*linkables)
      expect(body_printable).to include(*linkables)
    end

    it 'obfuscates using zero-width non-joiner chars' do
      obfuscator.run
      expect(body).to include("https\u200C://\u200Chacker\u200C.\u200Ccom")
      expect(body).to include("foo\u200C@\u200Cbar\u200C.\u200Cnl")
    end

    it 'does not change unlinkables' do
      obfuscator.run
      expect(body).to include(*unlinkables)
    end
  end

  context 'when mail has text part' do
    let(:mail) do
      Mail.new.tap { |mail| mail.text_part = content }
    end

    it 'obfuscates linkables' do
      obfuscator.run
      expect(text_part).not_to include(*linkables)
      expect(text_part_printable).to include(*linkables)
    end

    it 'does not change unlinkables' do
      obfuscator.run
      expect(text_part).to include(*unlinkables)
    end
  end

  context 'when mail has html part' do
    let(:mail) do
      Mail.new.tap { |mail| mail.html_part = content }
    end

    it 'obfuscates linkables' do
      obfuscator.run
      expect(html_part).not_to include(*linkables)
      expect(html_part_printable).to include(*linkables)
    end

    it 'does not change unlinkables' do
      obfuscator.run
      expect(html_part).to include(*unlinkables)
    end
  end

  context 'when mail has html and text part and url' do
    let(:mail) do
      Mail.new.tap do |mail|
        mail.text_part = 'http://good.org'
        mail.html_part = '<a href="http://good.org">good.org</a>'
      end
    end

    it 'does not change links in html part when used in anchor' do
      obfuscator.run
      expect(html_part).to include('http://good.org')
    end

    it 'does not change links in text part when used in anchor in html part' do
      obfuscator.run
      expect(text_part).to include('http://good.org')
    end
  end

  context 'when mail has html and text part and email' do
    let(:mail) do
      Mail.new.tap do |mail|
        mail.text_part = 'mail: (info@moneybird.com)'
        mail.html_part = '<a href="mailto:info@moneybird.com">email</a>'
      end
    end

    it 'does not change links in html part when used in anchor' do
      obfuscator.run
      expect(html_part).to include('info@moneybird.com')
    end

    it 'does not change links in text part when used in anchor in html part' do
      obfuscator.run
      expect(text_part).to include('info@moneybird.com')
    end
  end

  context 'when mail has script tags in html' do
    let(:mail) do
      Mail.new.tap { |mail| mail.html_part = '<script>var a = "foobar.com"</script>' }
    end

    it 'does not replace links' do
      obfuscator.run
      expect(html_part).to include('foobar.com')
    end
  end

  context 'when mail has escaped html' do
    let(:mail) do
      Mail.new.tap { |mail| mail.html_part = '&lt;img src=&quot;google.com&quot;&gt;' }
    end

    it 'does not unescape' do
      obfuscator.run
      expect(html_part).not_to include('<img src')
      expect(html_part).not_to include('google.com')
    end
  end

  context 'when mail contains unicode chars and transferred in quoted printable encoding' do
    let(:mail) do
      Mail.new.tap do |mail|
        mail.text_part = '€ hacker.com'
        mail.text_part.content_type = 'text/plain; charset=UTF-8'
        mail.text_part.content_transfer_encoding = 'quoted-printable'
      end
    end

    it 'obfuscates linkables' do
      obfuscator.run
      expect(text_part).not_to include('hacker.com')
    end
  end
end
