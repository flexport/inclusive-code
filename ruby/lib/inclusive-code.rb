# frozen_string_literal: true

require 'rubocop'

require_relative 'rubocop/inclusive_code'
require_relative 'rubocop/inclusive_code/version'
require_relative 'rubocop/inclusive_code/inject'

RuboCop::InclusiveCode::Inject.defaults!

require_relative 'rubocop/cop/inclusive_code'
