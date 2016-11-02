# MailAutoLinkObfuscation

This gem hooks up your Rails application and prevents email clients from automatically converting link-like text (e.g. `example.com`, `info@example.com`, `ftp://123.234.234.234`) to hyperlinks in your emails.

Automatic links can be an undesired feature, especially when user generated content is part of your emails, e.g. a user's name. If your user is called `your.enemy.com` and you insert his name directly in your mail, you will find that most email clients will make this name clickable. This effect can brake your email layout/design and even worse, it can be considered a security issue.

To prevent email clients from auto-linking any link-like text we have to outsmart their link parsers. Wrapping special link characters like `.`, `/` and `@` with invisible/non-printable [zero-width non-joiner](https://en.wikipedia.org/wiki/Zero-width_non-joiner) characters (Unicode U+200C) has shown to work for most email clients.

Example: `"Hello your.enemy.com!"` becomes `"Hello your\u200C.\u200Cenemy\u200C.\u200Ccom"`

Note that this module will not touch any explicit links mentioned in anchors in the `href` attribute. Those links are considered desired and trusted. If you provide HTML and text parts with your email (which you should) this gem is also smart enough not to change links in the text part if those have been explicitly hyperlinked in the HTML part.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mail_auto_link_obfuscation'
```

## Usage
Simply include `MailAutoLinkObfuscation::Automatic` in the mailers where you want obfuscate links.

```ruby
class MyMailer
  include MailAutoLinkObfuscation::Automatic
end
```

## Development

Specs can be run with `rake spec`. Guard is also available.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moneybird/mail_auto_link_obfuscation. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
