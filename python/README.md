This is a pylint custom checker to enforce a customizable inclusive language style guide.

## Installation

Install with poetry:
```
poetry add -D inclusive_code
```

Install with pip:
```
pip install inclusive_code
```

## Usage
Configure your own set of flagged terms following the structure of the `inclusive_code_flagged_terms.yml` file at the top level of this repo.

Add the following to your `.pylintrc`:
```
[MASTER]
load-plugins=inclusive_code

[INCLUSIVE CODE]

global-config-path=inclusive_code_flagged_terms.yml # set this to the relative path where you've stored your flagged terms file
```
Run the checkers by passing them with enable flags, ie
```
pylint --enable=inclusive-comments-violation --enable=inclusive-code-violation [files or dirs to run against]
```
