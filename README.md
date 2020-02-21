<p align="center">
  <img src="strainer.png" alt="Strainer Icon"/>
</p>

# Strainer

[![Gem Version](https://badge.fury.io/rb/strainer.svg)](http://badge.fury.io/rb/strainer)
<!-- Replace <id> with Code Climate repository ID. Remove this comment afterwards. -->
[![Code Climate Maintainability](https://api.codeclimate.com/v1/badges/<id>/maintainability)](https://codeclimate.com/github//strainer/maintainability)
[![Code Climate Test Coverage](https://api.codeclimate.com/v1/badges/<id>/test_coverage)](https://codeclimate.com/github//strainer/test_coverage)
[![Circle CI Status](https://circleci.com/gh//strainer.svg?style=svg)](https://circleci.com/gh//strainer)

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

  - [Requirements](#requirements)
  - [Usage](#usage)
  - [Tests](#tests)
  - [Versioning](#versioning)
  - [Code of Conduct](#code-of-conduct)
  - [Contributions](#contributions)
  - [License](#license)
  - [History](#history)
  - [Credits](#credits)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

## Requirements

1. [Ruby 2.6.5](https://www.ruby-lang.org)
2. [Rails 6.x]


## Usage

To install add the gem in your Gemfile.
This will downgrade some rails behavior to look like Rails 4 (for which behaviors are downgraded see lib/strainer/behaviors)

Adding a behavior:

Basic behavior looks like this (needs to be place in lib/strainer/behaviors):

```
module Strainer
  module Behaviors
    # Comment describng the override
    class {{BehaviorClassName}} < Strainer::RuntimeBehavior
      module {{ModuleThatImplementsOverride}}
        include Strainer::Logable

        def uniq(value = true)
          strainer_log('RELATION_UNIQ', custom: { relation_method: 'uniq' })
          distinct(value)
        end

      end

      def apply_patch!
        # Place code here that patches rails behavior
        # eg. to add this behavior to ActiveRecord::Relation do:
        # ActiveRecord::Relation.include({{ModuleThatImplementsOverride}})
      end
    end
  end
end

# To enable the patch onload of the railtie add this behavior in patches.rb

def self.setup!(component)
  case component
  when :action_controller
    load_behaviors Behaviors::ParametersAsHash
  when :active_record
    load_behaviors(
      Behaviors::ForcedReloading,
      Behaviors::RelationDelegationChanges,
      Behaviors::FinderChanges,
      Behaviors::RelationQueryMethodChanges,
      {{*Behaviors::BehaviorClassName*}},
    )
  end
end


```

## Tests

TBD

## Versioning

Read [Semantic Versioning](https://semver.org) for details. Briefly, it means:

- Major (X.y.z) - Incremented for any backwards incompatible public API changes.
- Minor (x.Y.z) - Incremented for new, backwards compatible, public API enhancements/fixes.
- Patch (x.y.Z) - Incremented for small, backwards compatible, bug fixes.

## Code of Conduct

Please note that this project is released with a [CODE OF CONDUCT](CODE_OF_CONDUCT.md). By
participating in this project you agree to abide by its terms.

## Contributions

Read [CONTRIBUTING](CONTRIBUTING.md) for details.

## License

Copyright 2019 []().
Read [LICENSE](LICENSE.md) for details.

## History

Read [CHANGES](CHANGES.md) for details.
Built with [Gemsmith](https://github.com/bkuhlmann/gemsmith).

## Credits

Developed by [Rishab Govind]() at
[]().
