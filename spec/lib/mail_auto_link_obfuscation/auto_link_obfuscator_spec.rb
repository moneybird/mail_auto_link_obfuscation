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
      'a.b.c. solutions b.v.'
    ]
  end

  let(:content) { (linkables + unlinkables).join(' ') }

  let(:body) { mail.body.decoded }
  let(:body_without_space) { body.gsub(/\s*/, '') }
  let(:body_without_tags) { body.gsub(/<[^>]*>/, '') }

  let(:text_part) { mail.text_part.body.decoded }
  let(:text_part_without_space) { text_part.gsub(/\s*/, '') }

  let(:html_part) { mail.html_part.body.decoded }
  let(:html_part_without_tags) { html_part.gsub(/<[^>]*>/, '') }

  context 'when mail has text body' do
    let(:mail) do
      Mail.new(body: content, content_type: 'text/plain')
    end

    it 'obfuscates linkables' do
      obfuscator.run
      expect(body).not_to include(*linkables)
      expect(body_without_space).to include(*linkables)
    end

    it 'obfuscates using spaces around key chars' do
      obfuscator.run
      expect(body).to include('https ://hacker .com')
      expect(body).to include('foo @bar .nl')
    end

    it 'does not change unlinkables' do
      obfuscator.run
      expect(body).to include(*unlinkables)
    end
  end

  context 'when mail has html body' do
    let(:mail) do
      Mail.new(body: content, content_type: 'text/html')
    end

    it 'obfuscates linkables' do
      obfuscator.run
      expect(body).not_to include(*linkables)
      expect(body_without_tags).to include(*linkables)
    end

    it 'obfuscates using span tags' do
      obfuscator.run
      expect(body).to include('https<span>://</span>hacker<span>.</span>com')
      expect(body).to include('foo<span>@</span>bar<span>.</span>nl')
    end

    context 'when span_style option is set' do
      let(:options) { { span_style: 'font:inherit' } }

      it 'applies style to span tags' do
        obfuscator.run
        expect(body).to include('foo<span style="font:inherit">@</span>bar<span style="font:inherit">.</span>nl')
      end
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
      expect(text_part_without_space).to include(*linkables)
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
      expect(html_part_without_tags).to include(*linkables)
    end

    it 'does not change unlinkables' do
      obfuscator.run
      expect(html_part).to include(*unlinkables)
    end
  end

  context 'when mail has html and text part' do
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

  context 'when mail has escaped html' do
    let(:mail) do
      Mail.new.tap { |mail| mail.html_part = "&lt;img src=&quot;google.com&quot;&gt;" }
    end

    it 'does not unescape' do
      obfuscator.run
      expect(html_part).not_to include('<img src')
      expect(html_part).not_to include('google.com')
    end
  end
end
