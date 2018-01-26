# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'mail_auto_link_obfuscation'

RSpec.configure do |config|
  config.filter_run_when_matching :focus

  config.order = :random

  config.seed = srand % 0xFFFF unless ARGV.any? { |arg| arg =~ /seed/ }
  Kernel.srand config.seed
end
