# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mail_auto_link_obfuscation/version'

Gem::Specification.new do |spec|
  spec.name          = 'mail_auto_link_obfuscation'
  spec.version       = MailAutoLinkObfuscation::VERSION
  spec.authors       = ['Oliver Jundt']
  spec.email         = ['info@moneybird.com']

  spec.summary       = 'Obfuscate link-like mail content on delivery to prevent auto hyperlinks in modern email clients.'
  spec.description   = 'Obfuscate link-like mail content on delivery to prevent auto hyperlinks in modern email clients.'
  spec.homepage      = 'https://github.com/moneybird/mail_auto_link_obfuscation'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'mail', '~> 2.5'
  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_dependency 'railties', '>= 3.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rails', '>= 3.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
end
