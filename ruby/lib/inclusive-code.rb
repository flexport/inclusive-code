# frozen_string_literal: true

require 'rubocop'

require_relative 'inclusive_code/flexport'
require_relative 'inclusive_code/flexport/version'
require_relative 'inclusive_code/flexport/inject'

RuboCop::Flexport::Inject.defaults!

require_relative 'inclusive_code/cop/inclusive_code'