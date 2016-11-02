# frozen_string_literal: true
require 'nokogiri'

module MailAutoLinkObfuscation
  class AutoLinkObfuscator
    AUTO_LINKED_EMAIL_PATTERN = /\S+@\w+(?:\.\w+)+/
    AUTO_LINKED_URL_PATTERN = %r{((\w+:)?//\w+(\.\w+)*|\w+(\.\w+)*\.\w{2,})\S*}
    AUTO_LINKED_PATTERN = Regexp.new([AUTO_LINKED_EMAIL_PATTERN, AUTO_LINKED_URL_PATTERN].join('|'))
    KEY_CHARS = %r{[@.:/]+}

    def initialize(mail, options)
      @mail = mail
      @options = options || {}
    end

    def run
      extract_link_whitelist_from_html
      transform_html_body if @mail.content_type == 'text/html'
      transform_text_body if @mail.content_type == 'text/plain'
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
      doc.xpath('//@href').map(&:content).to_set
    end

    def html_body_doc
      return unless @mail.content_type == 'text/html'
      @html_body_doc ||= Nokogiri::HTML(@mail.body.decoded)
    end

    def html_part_doc
      return unless @mail.html_part
      @html_part_doc ||= Nokogiri::HTML(@mail.html_part.body.decoded)
    end

    def transform_html_body
      @mail.body = transform_html(html_body_doc)
    end

    def transform_html_part
      @mail.html_part.body = transform_html(html_part_doc)
    end

    def transform_html(doc)
      doc.xpath('//body/descendant::text()').each do |node|
        content = transform_auto_linked_pattern(node.content) do |match|
          match.gsub(KEY_CHARS, span_template)
        end

        node.replace(content)
      end

      doc.to_s
    end

    def span_template
      @span_template ||= '<span' + (@options[:span_style] ? " style=#{@options[:span_style]}" : '') + '>\0</span>'
    end

    def transform_text_body
      @mail.body = transform_text(@mail.body.decoded)
    end

    def transform_text_part
      @mail.text_part.body = transform_text(@mail.text_part.body.decoded)
    end

    def transform_text(text)
      transform_auto_linked_pattern(text) do |match|
        match.gsub(KEY_CHARS, ' \0')
      end
    end

    def transform_auto_linked_pattern(text)
      text.gsub(AUTO_LINKED_PATTERN) do |match|
        @link_whitelist.include?(match) ? match : yield(match)
      end
    end
  end
end
