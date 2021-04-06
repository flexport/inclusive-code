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

```
require:
  - inclusive-code

Flexport/InclusiveCode:
  Enabled: true
  GlobalConfigPath: 'app/constants/inclusive_code/inclusive_code_flagged_terms.yml' # or your path
```

You can run the cop on your entire codebase with `rubocop --only Flexport/InclusiveCode`. 

You can run the cop on a specific file with `rubocop --only Flexport/InclusiveCode file_path`.
