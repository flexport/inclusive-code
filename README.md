# inclusive-code

## Installation
We're currently only supporting Ruby. See the README in the ruby directory for steps to install the gem.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/flexport/inclusive-code.
This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Style Guide
The following is Flexport's policy for writing inclusive code and documentation. We encourage you to adopt a similar policy.

### Guide To Writing Inclusive Code and Documentation

#### Related Reading
[Coding with Respect (Google Android)](https://source.android.com/setup/contribute/respectful-code)

[Writing inclusive documentation (Google Developers)](https://developers.google.com/style/inclusive-documentation)

#### Why

Flexport’s vision is to unite the world in a seamless web of commerce where it’s easy, affordable and predictable for companies to buy and sell products in any market, anywhere on Earth. To build the best possible product for a diverse, global audience, we need a diverse set of makers enabled to do their best work. 

In pursuit of creating an environment where everyone can do their best work, we will strive to avoid using terminology that is derogatory, hurtful, or perpetuates discrimination, either directly or indirectly [ref](https://source.android.com/setup/contribute/respectful-code). We acknowledge that the tech industry does not accurately reflect population demographics, and as a result there is established terminology that is harmful to underrepresented groups. 

For example, using ‘whitelist’ and ‘blacklist’ as shorthand for positive/good/allowed and negative/bad/denied is an established pattern in the industry. For people who are constantly dealing with the reality of those cultural connotations, seeing them reinforced in the codebase can be harmful. Similarly, using phrases like ‘sanity check’ and ‘insane’ evokes ableist stereotypes for non-neurotypical people.

We believe we can do our best work by welcoming the most diverse set of makers possible, and so we embrace the change that comes with them.

#### Scope

This style guide applies but is not limited to:
* All internal code, in all languages
  * Includes variables, methods, data models, files, and classes
  * Does not include external libraries and generated files
* Tests and test cases
* Comments and documentation inside and outside the codebase
* UIs and APIs, internals and output
* Commit messages, PR descriptions, and code reviews
* Data storage: table names, columns, etc.

#### Guiding Principles [ref](https://source.android.com/setup/contribute/respectful-code)

Be respectful: Derogatory language shouldn’t be necessary to describe how things work.
Use culturally appropriate language: Some words might have significant historical or political meanings. Please consider this and use alternatives.

#### Examples

Though this is not comprehensive, in general we want to avoid using language that is racist, ableist, or gendered.

Example of writing that is racist

🚫 value "WHITELISTED", "The value is currently whitelisted by a switch"
🚫 value "BLACKLISTED", "The value is currently blacklisted by a switch"

✅ value "ALLOWLISTED", "The value is currently allowlisted by a switch"
✅ value "BLOCKLISTED", "The value is currently blocklisted by a switch"

Example of writing that is ableist

🚫 def sanity_check_dockerfiles(dockerfiles)

✅ def check_dockerfiles(...)

Example of writing that is gendered

🚫 This is the measurement of man-hours and touchpoints across the bill ingestion process…

✅ This is the measurement of working-hours and touchpoints across the bill ingestion process…

#### Flagged Terms and Alternatives

Term | Suggested Alternative(s)
-----|----------------------------
whitelist/blacklist | Allowlist/blocklist, Includelist/excludelist
master/slave | Leader/follower, Primary/secondary, Primary/replica, Parent/child
master | Main, original, primary
master data | Main data, reference data
redline | Priority line, exception, anomaly
sanity check | Check, validity check, make sure you’re using types correctly, sensibile/reasonable/reasonability check
crippled | Slowed, overloaded 
grandfathered | Exempt, legacy
dummy | Placeholder, mock
gendered pronouns | They, them, their
man-in-the-middle | On-path attack, person-in-the-middle
first-class citizen | First class concern/concept, core concern, built in, top-level 

#### Industry Term Exemption

It occurs that some flagged terms are a part of deeply ingrained freight industry jargon.  For example, the ‘Master Bill of Lading’ is a core document and data model in ocean freight, and a ‘Segregation Order’ is a consolidation document. In the freight forwarding context, ‘Segregation Order’ has a meaning to our users and partners that ‘Separation Order’ does not. Whether for compliance purposes or for clarity/adoption, it is sometimes necessary to preserve uses of these terms in the codebase.  


Portions of this page are reproduced from, or are modifications based on, work created and [shared by the Android Open Source Project](https://code.google.com/p/android/) and work created and [shared by Google](https://developers.google.com/readme/policies) and used according to terms described in the [Creative Commons 4.0 Attribution License](https://creativecommons.org/licenses/by/4.0/).
