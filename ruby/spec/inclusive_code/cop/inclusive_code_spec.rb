# typed: false
# TEAM: devex
require "rubocop_spec_helper"

describe InclusiveCode::Cop::InclusiveCode do
  subject(:cop) { described_class.new }

  let(:msg) { InclusiveCode::Cop::InclusiveCode::MSG }
  let(:words_hash) { InclusiveCode::Cop::InclusiveCode::NON_INCLUSIVE_WORDS_ALTERNATIVES_HASH }

  decsribe "inclusive code" do
    context "when non-inclusive language is used" do
      context "in a function" do
        let(:source) do
          <<~RUBY
            module Master
                  ^^^^^^ #{format(
                    msg, 
                    non_inclusive_word: 'master', 
                    suggestions: words_hash['master']['suggestions'].join(', '),
                  )}
              Shipment = Struct.new
            end
          RUBY
        end

        it "does add offenses" do
          expect_offense(source)
        end
      end

      context "in a comment" do
        let(:source) do
          <<~RUBY
            # dummy
              ^^^^^ #{format(
                msg, 
                non_inclusive_word: 'dummy', 
                suggestions: words_hash['dummy']['suggestions'].join(', '),
              )}
          RUBY
        end

        it "does add offenses" do
          expect_offense(source)
        end
      end

      context "multiple times in one line" do
        let(:source) do
          <<~RUBY
            puts "grandfathered MAN-IN-THE-MIDDLE"
                                ^^^^^^^^^^^^^^^^^ #{format(
                                  msg, 
                                  non_inclusive_word: 'man-in-the-middle', 
                                  suggestions: words_hash['man-in-the-middle']['suggestions'].join(', '),
                                )}
                  ^^^^^^^^^^^^^ #{format(
                    msg, 
                    non_inclusive_word: 'grandfathered', 
                    suggestions: words_hash['grandfathered']['suggestions'].join(', '),
                  )}
          RUBY
        end

        it "does add offenses" do
          expect_offense(source)
        end
      end

      context "in a file name" do
        let(:file) { "/engines/master_engine/app/services/" }
        let(:source) do
          # file name offenses show up with the first character of the file highlighted
          <<~RUBY
            class MyInclusiveEngine
            ^ #{format(
              msg, 
              non_inclusive_word: 'master', 
              suggestions: words_hash['master']['suggestions'].join(', '),
            )}
              puts "Hooray for inclusion!"
            end
          RUBY
        end

        it "adds offense" do
          expect_offense(source, file)
        end
      end
    end

    context "when no flagged terms are present" do
      context "in some code" do
        let(:source) do
          <<~RUBY
            puts "Bob Loblaw Law Blog"
            puts "inclusive words"
          RUBY
        end

        it "does not add offenses" do
          expect_no_offenses(source)
        end
      end
    end

    context "when allowed terms are present" do
      context "in some code, in both PascalCase and snake_case" do
        let(:source) do
          <<~RUBY
            puts "master bill of lading"
            puts "master_bill_of_lading"
            puts "OceanMasterBillOfLading"
          RUBY
        end

        it "does not add offenses" do
          expect_no_offenses(source)
        end
      end
    end

    context "when allowed terms and non-inclusive language are present" do
      context "in some code" do
        let(:source) do
          <<~RUBY
            puts "master bill of lading master blacklist"
                                              ^^^^^^^^^ #{format(
                                                msg, 
                                                non_inclusive_word: 'blacklist', 
                                                suggestions: words_hash['blacklist']['suggestions'].join(', '),
                                              )}
                                        ^^^^^^ #{format(
                                          msg, 
                                          non_inclusive_word: 'master', 
                                          suggestions: words_hash['master']['suggestions'].join(', '),
                                        )}
            puts "master_air_waybill"
          RUBY
        end

        it "does add offenses" do
          expect_offense(source)
        end
      end
    end
  end

  describe "#autocorrect" do
    context "when there is one offense" do
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

      it "corrects the offense" do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(fixed_source)
      end
    end

    context "when there are multiple offenses" do
      let(:source) do
        <<~RUBY
          BLACKLIST_CODES = ["AF", "AO", "BO", "IQ", "NG", "PY", "KP"].freeze
          private_constant :BLACKLIST_CODES
          BLACKLIST_COUNTRIES = "blacklist_countries".freeze
        RUBY
      end
      let(:fixed_source) do
        <<~RUBY
          BLOCKLIST_CODES = ["AF", "AO", "BO", "IQ", "NG", "PY", "KP"].freeze
          private_constant :BLOCKLIST_CODES
          BLOCKLIST_COUNTRIES = "blocklist_countries".freeze
        RUBY
      end

      it "corrects all offenses" do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(fixed_source)
      end
    end
  end
end