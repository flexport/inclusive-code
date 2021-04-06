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

        SEVERITY = 'warning'.freeze

        MSG = '🚫 Use of non_inclusive word: `%<non_inclusive_word>s`. Consider using these suggested alternatives: `%<suggestions>s`.'.freeze

        def initialize(config = nil, options = nil, source_file = nil)
          super(config, options)
  
          source_file ||= YAML.load_file(cop_config['GlobalConfigPath'])
          @non_inclusive_words_alternatives_hash = source_file['flagged_terms']
          @all_non_inclusive_words = @non_inclusive_words_alternatives_hash.keys
          @non_inclusive_words_regex = Regexp.new(
            @all_non_inclusive_words.join('|'),
            Regexp::IGNORECASE
          )
          @allowed = @all_non_inclusive_words.collect do |word|
            [
              word,
              get_allowed_string(word)
            ]
          end.to_h
          @allowed_regex = Regexp.new(@allowed.values.reject(&:blank?).join('|'), Regexp::IGNORECASE)
        end

        def investigate(processed_source)
          processed_source.lines.each_with_index do |line, line_number|
            next unless line.match(@non_inclusive_words_regex)

            @all_non_inclusive_words.each do |non_inclusive_word|
              allowed = @allowed[non_inclusive_word]
              scan_regex = if allowed.blank?
                             /(?=#{non_inclusive_word})/i
                           else
                             /(?=#{non_inclusive_word})(?!(#{@allowed[non_inclusive_word]}))/i
                           end
              locations = line.enum_for(
                :scan,
                scan_regex
              ).map { Regexp.last_match&.offset(0)&.first }
              next if locations.blank?

              locations.each do |location|
                range = source_range(
                  processed_source.buffer,
                  line_number + 1,
                  location,
                  non_inclusive_word.length
                )
                add_offense(
                  range,
                  location: range,
                  message: create_message(non_inclusive_word),
                  severity: SEVERITY
                )
              end
            end
          end
          # Also error for non-inclusive language in file names
          path = processed_source.path
          return if path.nil?

          non_inclusive_words_match = path.match(@non_inclusive_words_regex)
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
          word_to_correct_downcase = word_to_correct.downcase
          return unless @non_inclusive_words_alternatives_hash.key?(word_to_correct_downcase)
          return if @non_inclusive_words_alternatives_hash[word_to_correct_downcase]['suggestions'].blank?

          corrected = @non_inclusive_words_alternatives_hash[word_to_correct_downcase]['suggestions'][0]

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

        def get_allowed_string(non_inclusive_word)
          allowed = @non_inclusive_words_alternatives_hash[non_inclusive_word]['allowed']
          snake_case = allowed.map { |e| e.tr(' ', '_').underscore }
          pascal_case = snake_case.map(&:camelize)
          (allowed + snake_case + pascal_case).join('|')
        end

        def create_message(non_inclusive_word)
          format(
            MSG,
            non_inclusive_word: non_inclusive_word,
            suggestions: @non_inclusive_words_alternatives_hash[non_inclusive_word]['suggestions'].join(', ')
          )
        end
      end
    end
  end
end
