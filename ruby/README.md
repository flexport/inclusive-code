## Installation

Add this line to your application's Gemfile:

```ruby
gem 'inclusive-code'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install inclusive-code

## Usage
Configure your own set of flagged terms following the structure of the `inclusive_code_flagged_terms.yml` file at the top level of this repo. We recommend storing it in `'app/constants/inclusive_code/inclusive_code_flagged_terms.yml'`.

Put this into your .rubocop.yml:

```yaml
require:
  - inclusive-code

Flexport/InclusiveCode:
  Enabled: true
  GlobalConfigPath: 'app/constants/inclusive_code/inclusive_code_flagged_terms.yml' # or your path
  DisableAutoCorrect: false
```

You can run the cop on your entire codebase with `rubocop --only Flexport/InclusiveCode`.

You can run the cop on a specific file with `rubocop --only Flexport/InclusiveCode file_path`.

If you want to add inline `rubocop:disable` or `rubocop:todo` comments on all offenses, set `DisableAutoCorrect: true` in your .rubocop.yml, and run `rubocop --only Flexport/InclusiveCode --auto-correct --disable-uncorrectable`.

## Configuration

The inclusive-code gem includes an initial configuration to get your project started. You can customize this configuration to fit your needs.

### Flagging harmful terms

Rules are added under the key `flagged_term` as follows:

```yaml
---
flagged_terms:
  another_harmful_term:
    suggestions:
      - an_appropriate_alternative
    allowed: []
```

### Specifying harmful terminology

You can specify harmful terminology using basic keys (`another_harmful_term:`), string keys (`" his ":`), or using [regular expressions](https://rubular.com/r/HvcomHUBZ3KFCz) like `"white[-_\\s]*list":`. Please note that when specifying a regular expression, some characters (`\`) may need to be escaped.

### Allowing exceptions

This gem supports two ways to specify exceptions to your rules: allowing specific terms, allowing specific files.

#### Allowing specific terms

You might want to do this to allow for an [Industry Term Exception](../README.md#industry-term-exemption). Here's how to allow certain terms using the `allowed:` key:

```yaml
---
flagged_terms:
  master:
    suggestions:
      - main
    allowed:
      - master bill
      - master air waybill
      - master consol
      - master shipment
```

#### Allowing specific files

You might want to do this when you wish to disallow some term, but you need to allow it in certain files. Perhaps you rely on some library which requires you to configure it using some harmful terminology. Here's how to allow occurrences of a harmful term when they occur within some file using the `allowed_files:` key:

```yaml
---
flagged_terms:
  whitelist:
    suggestions:
      - main
    allowed_files:
      - config/initializers/some_gem_config.rb
      - .some_gem/*
```

This will would result in allowing offenses in any files returned by `Dir.glob("{config/initializers/some_gem_config.rb,.some_gem/*}")`

### Suggestions and Autocorrect

In a document titled [Terminology, Power and Offensive Language](https://tools.ietf.org/id/draft-knodel-terminology-01.html), the Internet Engineering Task Force (IETF) recommends that an editor or reviewer *should* "offer alternatives for offensive terminology as an important act of correcting larger editorial issues and clarifying technical concepts."

As this gem does some of the work of an editor or reviewer, it is appropriate that it should allow for communicating better alternatives when it finds harmful terminology.

When using autocorrect, the first item in the suggestions array will be used as the autocorrect term.
