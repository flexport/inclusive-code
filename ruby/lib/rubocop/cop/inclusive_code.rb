# frozen_string_literal: true

require 'active_support/core_ext/string'

module RuboCop
  module Cop
    module Flexport
      # This cop encourages use of inclusive language to help programmers avoid
      # using terminology that is derogatory, hurtful, or perpetuates discrimination,
      # either directly or indirectly, in their code.
      #
      # @example
      #
      #   # bad
      #
      #   BLACKLIST_COUNTRIES = "blacklist_countries".freeze
      #
      # @example
      #
      #   # good
      #
      #   BLOCKLIST_COUNTRIES = "blocklist_countries".freeze
      #
      #
      class InclusiveCode < Cop
        include RangeHelp

        SEVERITY = 'warning'

        FLAG_ONLY_MSG = '🚫 Use of non_inclusive word: `%<non_inclusive_word>s`.'
        FULL_FLAG_MSG = "#{FLAG_ONLY_MSG} Consider using these suggested alternatives: `%<suggestions>s`."

        ALLOWED_TERM_MASK_CHAR = '*'.freeze

        def initialize(config = nil, options = nil, source_file = nil)
          super(config, options)

          source_file ||= YAML.load_file(cop_config['GlobalConfigPath'])
          @non_inclusive_words_alternatives_hash = source_file['flagged_terms']
          @all_non_inclusive_words = @non_inclusive_words_alternatives_hash.keys
          @non_inclusive_words_regex = concatenated_regex(@all_non_inclusive_words)
          @allowed_terms = {}
          @allowed_files = {}

          @all_non_inclusive_words.each do |word|
            @allowed_terms[word] = get_allowed_string(word)
            @allowed_files[word] = source_file['flagged_terms'][word]['allowed_files'] || []
          end
          @allowed_regex = @allowed_terms.values.reject(&:blank?).join('|')

          @allowed_regex = if @allowed_regex.blank?
                             Regexp.new(/^$/)
                           else
                             Regexp.new(@allowed_regex, Regexp::IGNORECASE)
                           end
        end

        def investigate(processed_source)
          non_inclusive_words_for_current_file = @all_non_inclusive_words.reject do |non_inclusive_word|
            Dir.glob("{#{@allowed_files[non_inclusive_word].join(',')}}").include?(processed_source.path)
          end

          processed_source.lines.each_with_index do |line, line_number|
            next unless line.match(@non_inclusive_words_regex)

            non_inclusive_words_for_current_file.each do |non_inclusive_word|
              allowed = @allowed_terms[non_inclusive_word]
              scan_regex = /(?=#{non_inclusive_word})/i
              if allowed.present?
                line = line.gsub(/(#{allowed})/i){ |match| ALLOWED_TERM_MASK_CHAR * match.size }
              end
              locations = line.enum_for(
                :scan,
                scan_regex
              ).map { Regexp.last_match&.offset(0)&.first }

              non_inclusive_words = line.scan(/#{non_inclusive_word}/i)

              locations = locations.zip(non_inclusive_words).to_h
              next if locations.blank?

              locations.each do |location, word|
                range = source_range(
                  processed_source.buffer,
                  line_number + 1,
                  location,
                  word.length
                )
                add_offense(
                  range,
                  location: range,
                  message: create_message(word),
                  severity: SEVERITY
                )
              end
            end
          end
          # Also error for non-inclusive language in file names
          path = processed_source.path
          return if path.nil?

          non_inclusive_words_match = path.match(concatenated_regex(non_inclusive_words_for_current_file))
          return unless non_inclusive_words_match && !path.match(@allowed_regex)

          range = source_range(processed_source.buffer, 1, 0)
          add_offense(
            range,
            location: range,
            message: create_message(non_inclusive_words_match[0]),
            severity: SEVERITY
          )
        end

        def autocorrect(arg_pair)
          return if cop_config['DisableAutoCorrect']

          word_to_correct = arg_pair.source
          correction = correction_for_word(word_to_correct)
          return if correction['suggestions'].blank?

          corrected = correction['suggestions'][0]

          # Only respects case if it is capitalized or uniform (all upper or all lower)
          to_upcase = word_to_correct == word_to_correct.upcase
          if to_upcase
            corrected = corrected.upcase
          elsif word_to_correct == word_to_correct.capitalize
            corrected = corrected.capitalize
          end

          lambda do |corrector|
            corrector.insert_before(arg_pair, corrected)
            corrector.remove(arg_pair)
          end
        end

        private

        def concatenated_regex(non_inclusive_words)
          Regexp.new(
            non_inclusive_words.join('|'),
            Regexp::IGNORECASE
          )
        end

        def get_allowed_string(non_inclusive_word)
          allowed = @non_inclusive_words_alternatives_hash[non_inclusive_word].fetch('allowed') { [] }
          snake_case = allowed.map { |e| e.tr(' ', '_').underscore }
          pascal_case = snake_case.map(&:camelize)
          (allowed + snake_case + pascal_case).join('|')
        end

        def correction_for_word(word_to_correct)
          _, correction = @non_inclusive_words_alternatives_hash.detect do |correction_key, _|
            Regexp.new(correction_key, Regexp::IGNORECASE).match?(word_to_correct.downcase)
          end

          correction || {}
        end

        def create_message(non_inclusive_word)
          correction = correction_for_word(non_inclusive_word)
          suggestions = correction.fetch('suggestions') { [] }.join(', ')

          format(
            suggestions.present? ? FULL_FLAG_MSG : FLAG_ONLY_MSG,
            non_inclusive_word: non_inclusive_word,
            suggestions: suggestions
          )
        end
      end
    end
  end
end
