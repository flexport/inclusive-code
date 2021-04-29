# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Flexport::InclusiveCode do
  subject(:cop) do
    described_class.new(nil, nil, YAML.load_file(
                                    File.expand_path('../../../../inclusive_code_flagged_terms.yml', __dir__)
                                  ))
  end

  let(:msg) { RuboCop::Cop::Flexport::InclusiveCode::MSG }
  let(:words_hash) { cop.instance_variable_get('@non_inclusive_words_alternatives_hash') }

  describe 'inclusive code' do
    context 'when non-inclusive language is used' do
      context 'in a function' do
        let(:source) do
          <<~RUBY
            module Master
                   ^^^^^^ #{format(
                     msg,
                     non_inclusive_word: 'Master',
                     suggestions: words_hash['master']['suggestions'].join(', ')
                   )}
              Shipment = Struct.new
            end
          RUBY
        end

        it 'does add offenses' do
          expect_offense(source)
        end
      end

      context 'in a comment' do
        let(:source) do
          <<~RUBY
            # dummy
              ^^^^^ #{format(
                msg,
                non_inclusive_word: 'dummy',
                suggestions: words_hash['dummy']['suggestions'].join(', ')
              )}
          RUBY
        end

        it 'does add offenses' do
          expect_offense(source)
        end
      end

      context 'multiple times in one line' do
        let(:source) do
          <<~RUBY
            puts "grandfathered MAN-IN-THE-MIDDLE"
                                ^^^^^^^^^^^^^^^^^ #{format(
                                  msg,
                                  non_inclusive_word: 'MAN-IN-THE-MIDDLE',
                                  suggestions: words_hash['man-in-the-middle']['suggestions'].join(', ')
                                )}
                  ^^^^^^^^^^^^^ #{format(
                    msg,
                    non_inclusive_word: 'grandfathered',
                    suggestions: words_hash['grandfathered']['suggestions'].join(', ')
                  )}
          RUBY
        end

        it 'does add offenses' do
          expect_offense(source)
        end
      end

      context 'in a file name' do
        let(:file) { '/engines/master_engine/app/services/' }
        let(:source) do
          # file name offenses show up with the first character of the file highlighted
          <<~RUBY
            class MyInclusiveEngine
            ^ #{format(
              msg,
              non_inclusive_word: 'master',
              suggestions: words_hash['master']['suggestions'].join(', ')
            )}
              puts "Hooray for inclusion!"
            end
          RUBY
        end

        it 'adds offense' do
          expect_offense(source, file)
        end
      end
    end

    context 'when non-inclusive terms are present in an allowed file' do
      let(:flagged_terms) do
        {
          'flagged_terms' => {
            'rubocop' => {
              'suggestions' => ['ruby_enforcement_service'],
              'allowed' => [],
              'allowed_files' => ['README.md', 'lib/rubocop/cop/inclusive_code.rb']
            },
            'other_offensive_term' => {
              'suggestions' => ['non_offensive_terms'],
              'allowed' => [],
              'allowed_files' => []
            }
          }
        }
      end

      subject(:cop) do
        described_class.new(nil, nil, flagged_terms)
      end

      it 'ignores filename offenses in an allowed file but does not ignore them in another file' do
        source = <<~RUBY
          puts "Hooray for inclusion!"
          ^ #{format(
            msg,
            non_inclusive_word: 'rubocop',
            suggestions: 'ruby_enforcement_service'
          )}
        RUBY

        expect_no_offenses(source.lines.first, 'lib/rubocop/cop/inclusive_code.rb')
        expect_offense(source, 'lib/rubocop/inclusive_code/version.rb')
      end

      it 'allows offenses in an allowed file while detecting other offenses in the same file' do
        source = <<~RUBY
          puts "rubocop"
          puts "other_offensive_term"
                ^^^^^^^^^^^^^^^^^^^^ #{format(
                  msg,
                  non_inclusive_word: 'other_offensive_term',
                  suggestions: 'non_offensive_terms'
                )}
        RUBY
        expect_offense(source, 'README.md')
      end
    end

    context 'when no flagged terms are present' do
      context 'in some code' do
        let(:source) do
          <<~RUBY
            puts "Bob Loblaw Law Blog"
            puts "inclusive words"
          RUBY
        end

        it 'does not add offenses' do
          expect_no_offenses(source)
        end
      end
    end

    context 'when allowed terms are present' do
      context 'in some code, in both PascalCase and snake_case' do
        let(:source) do
          <<~RUBY
            puts "master bill of lading"
            puts "master_bill_of_lading"
            puts "OceanMasterBillOfLading"
          RUBY
        end

        it 'does not add offenses' do
          expect_no_offenses(source)
        end
      end
    end

    context 'when allowed terms and non-inclusive language are present' do
      context 'in some code' do
        let(:source) do
          <<~RUBY
            puts "master bill of lading master blacklist"
                                               ^^^^^^^^^ #{format(
                                                 msg,
                                                 non_inclusive_word: 'blacklist',
                                                 suggestions: cop.send(:correction_for_word, 'blacklist')['suggestions'].join(', ')
                                               )}
                                        ^^^^^^ #{format(
                                          msg,
                                          non_inclusive_word: 'master',
                                          suggestions: cop.send(:correction_for_word, 'master')['suggestions'].join(', ')
                                        )}
            puts "master_air_waybill"
          RUBY
        end

        it 'does add offenses' do
          expect_offense(source)
        end
      end
    end
  end

  describe '#autocorrect' do
    context 'when there is one offense' do
      let(:source) do
        <<~RUBY
          class Blacklist < ApplicationRecord
            puts "not whitelist"
          end
        RUBY
      end
      let(:fixed_source) do
        <<~RUBY
          class Blocklist < ApplicationRecord
            puts "not allowlist"
          end
        RUBY
      end

      it 'corrects the offense' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(fixed_source)
      end
    end

    context 'when there are multiple offenses' do
      let(:source) do
        <<~RUBY
          BLACK_LIST_CODES = ["AF", "AO", "BO", "IQ", "NG", "PY", "KP"].freeze
          private_constant :BLACK_LIST_CODES
          BLACK_LIST_COUNTRIES = "blacklist_countries".freeze
        RUBY
      end
      let(:fixed_source) do
        <<~RUBY
          BLOCKLIST_CODES = ["AF", "AO", "BO", "IQ", "NG", "PY", "KP"].freeze
          private_constant :BLOCKLIST_CODES
          BLOCKLIST_COUNTRIES = "blocklist_countries".freeze
        RUBY
      end

      it 'corrects all offenses' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(fixed_source)
      end
    end
  end
end
