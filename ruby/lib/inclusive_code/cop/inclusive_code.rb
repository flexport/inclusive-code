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

        SEVERITY = "warning".freeze

        MSG = "🚫 Use of non_inclusive word: `%<non_inclusive_word>s`. Consider using these suggested alternatives: `%<suggestions>s`.".freeze

        NON_INCLUSIVE_WORDS_ALTERNATIVES_HASH = YAML.load_file(File.expand_path(
          "../../../../../inclusive_code_flagged_terms.yml",
          __dir__,
        ))["flagged_terms"]

        ALL_NON_INCLUSIVE_WORDS = NON_INCLUSIVE_WORDS_ALTERNATIVES_HASH.keys

        NON_INCLUSIVE_WORDS_REGEX = Regexp.new(
          ALL_NON_INCLUSIVE_WORDS.join("|"),
          Regexp::IGNORECASE,
        )

        def self.get_allowed_string(non_inclusive_word)
          allowed = NON_INCLUSIVE_WORDS_ALTERNATIVES_HASH[non_inclusive_word]["allowed"]
          snake_case = allowed.map { |e| e.tr(" ", "_").underscore }
          pascal_case = snake_case.map(&:camelize)
          (allowed + snake_case + pascal_case).join("|")
        end

        ALLOWED = ALL_NON_INCLUSIVE_WORDS.collect do |word|
          [
            word,
            get_allowed_string(word),
          ]
        end.to_h

        ALLOWED_REGEX = Regexp.new(ALLOWED.values.reject(&:blank?).join("|"), Regexp::IGNORECASE)

        def investigate(processed_source)
          processed_source.lines.each_with_index do |line, line_number|
            if line.match(NON_INCLUSIVE_WORDS_REGEX)
              ALL_NON_INCLUSIVE_WORDS.each do |non_inclusive_word|
                allowed = ALLOWED[non_inclusive_word]
                if allowed.blank?
                  scan_regex = /(?=#{non_inclusive_word})/i
                else
                  scan_regex = /(?=#{non_inclusive_word})(?!(#{ALLOWED[non_inclusive_word]}))/i
                end
                locations = line.enum_for(
                  :scan,
                  scan_regex,
                ).map { Regexp.last_match&.offset(0)&.first }
                next if locations.blank?
                locations.each do |location|
                  range = source_range(
                    processed_source.buffer,
                    line_number + 1,
                    location,
                    non_inclusive_word.length,
                  )
                  add_offense(
                    range,
                    location: range,
                    message: create_message(non_inclusive_word),
                    severity: SEVERITY,
                  )
                end
              end
            end
          end
          # Also error for non-inclusive language in file names
          path = processed_source.path
          if path.nil?
            return
          end
          non_inclusive_words_match = path.match(NON_INCLUSIVE_WORDS_REGEX)
          if non_inclusive_words_match && !path.match(ALLOWED_REGEX)
            range = source_range(processed_source.buffer, 1, 0)
            add_offense(
              range,
              location: range,
              message: create_message(non_inclusive_words_match[0]),
              severity: SEVERITY,
            )
          end
        end

        def autocorrect(arg_pair)
          word_to_correct = arg_pair.source
          word_to_correct_downcase = word_to_correct.downcase
          return if !NON_INCLUSIVE_WORDS_ALTERNATIVES_HASH.key?(word_to_correct_downcase)
          return if NON_INCLUSIVE_WORDS_ALTERNATIVES_HASH[word_to_correct_downcase]["suggestions"].blank?
          corrected = NON_INCLUSIVE_WORDS_ALTERNATIVES_HASH[word_to_correct_downcase]["suggestions"][0]

          # Only respects case if it is capitalized or uniform (all upper or all lower)
          to_upcase = word_to_correct == word_to_correct.upcase
          if to_upcase
            corrected = corrected.upcase
          elsif word_to_correct == word_to_correct.capitalize
            corrected = corrected.capitalize
          end

          ->(corrector) do
            corrector.insert_before(arg_pair, corrected)
            corrector.remove(arg_pair)
          end
        end

        private

        def create_message(non_inclusive_word)
          format(
            MSG,
            non_inclusive_word: non_inclusive_word,
            suggestions: NON_INCLUSIVE_WORDS_ALTERNATIVES_HASH[non_inclusive_word]["suggestions"].join(", "),
          )
        end
      end
    end
  end
end