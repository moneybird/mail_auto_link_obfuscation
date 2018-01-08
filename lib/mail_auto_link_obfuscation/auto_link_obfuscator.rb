# frozen_string_literal: true

require 'nokogiri'

module MailAutoLinkObfuscation
  class AutoLinkObfuscator
    AUTO_LINKED_EMAIL_PATTERN = /[\w\.%+-]+@\w+(?:\.\w+)+/
    AUTO_LINKED_URL_PATTERN = %r{(?:(?:\w+:)?//\w+(?:\.\w+)*|\w+(?:\.\w+)*\.\w{2,}(?!\.\w+))\S*}
    AUTO_LINKED_PATTERN = Regexp.new([AUTO_LINKED_EMAIL_PATTERN, AUTO_LINKED_URL_PATTERN].join('|'))
    KEY_CHARS = %r{[@.]+|:*//+}

    def initialize(mail, options)
      @mail = mail
      @options = options || {}
    end

    def run
      extract_link_whitelist_from_html
      transform_html_body if @mail.content_type.include? 'text/html'
      transform_text_body if @mail.content_type.include? 'text/plain'
      transform_html_part if @mail.html_part
      transform_text_part if @mail.text_part
      @mail
    end

    def extract_link_whitelist_from_html
      @link_whitelist =
        extract_link_whitelist_from(html_body_doc) +
        extract_link_whitelist_from(html_part_doc)
    end

    def extract_link_whitelist_from(doc)
      return Set.new unless doc
      whitelist = doc.xpath('//@href').map { |href| href.content.sub(/\Amailto:/, '') }.to_set
      whitelist.merge(whitelist.map { |href| href.sub(%r{\A[a-z]+://}, '') })
    end

    def html_body_doc
      return unless @mail.content_type.include? 'text/html'
      @html_body_doc ||= Nokogiri::HTML(@mail.decoded)
    end

    def html_part_doc
      return unless @mail.html_part
      @html_part_doc ||= Nokogiri::HTML(@mail.html_part.decoded)
    end

    def transform_html_body
      @mail.body = transform_html(html_body_doc)
    end

    def transform_html_part
      @mail.html_part.body = transform_html(html_part_doc)
    end

    def transform_html(doc)
      doc.xpath('//body/descendant::text()').each do |node|
        text = CGI.escapeHTML(node.content)
        node.replace(transform_text(text))
      end

      doc.to_s
    end

    def transform_text_body
      @mail.body = transform_text(@mail.decoded)
    end

    def transform_text_part
      @mail.text_part.body = transform_text(@mail.text_part.decoded)
    end

    def transform_text(text)
      transform_auto_linked_pattern(text) do |match|
        match.gsub(KEY_CHARS, "\u200C\\0\u200C")
      end
    end

    def transform_auto_linked_pattern(text)
      text.gsub(AUTO_LINKED_PATTERN) do |match|
        @link_whitelist.include?(match) ? match : yield(match)
      end
    end
  end
end
