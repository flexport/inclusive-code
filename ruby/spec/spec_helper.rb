# frozen_string_literal: true

require 'inclusive-code'
require 'rubocop'
require 'rubocop/rspec/cop_helper'
require 'rubocop/rspec/expect_offense'
require 'rubocop/rspec/support'

RSpec.configure do |config|
  config.include(CopHelper)
  config.include RuboCop::RSpec::ExpectOffense

  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.raise_on_warning = true
  config.fail_if_no_examples = true

  config.order = :random
  Kernel.srand config.seed
end
