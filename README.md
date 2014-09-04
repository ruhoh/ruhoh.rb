[![Stories in Ready](https://badge.waffle.io/ruhoh/ruhoh.rb.png?label=ready)](https://waffle.io/ruhoh/ruhoh.rb)  
[![Build Status](https://travis-ci.org/ruhoh/ruhoh.rb.png?branch=master)](https://travis-ci.org/ruhoh/ruhoh.rb)

## Ruhoh is the Universal Static Blog API

Usage and quick start information at <http://ruhoh.com>

### Running the Latest Version

All official releases are pushed out to <http://rubygems.org/gems/ruhoh> which can be used with bundler via Gemfile entry:

```ruby
gem 'ruhoh'
```

The master branch will refer to the next version and can be used in the Gemfile:

```ruby
gem 'ruhoh', :git => "git@github.com:ruhoh/ruhoh.rb.git"
```

### Platforms

ruhoh has official support for ruby 1.9.2, 1.9.3, ruby 2.0.0
ruhoh runs in production with ruby 1.9.2 on Ubuntu 10.04.4 LTS.

ruby 1.8.7 is not supported.

**Windows**

ruhoh should run on Windows with a few considerations:

If you run into trouble with YAML and psych see: https://github.com/ruhoh/ruhoh.rb/issues/54
More help is available here: https://github.com/ruhoh/ruhoh.rb/issues/search?q=windows

I can't easily test ruhoh on a Windows machine, so please consider contributing back to the community for running on Windows.

### Contributing

I enjoy getting better at managing contributions so all skill levels are welcome.

Tips to ensure your work has the best chance of getting merged in:

- Feel free to ask for guidance at any time via issues, twitter, or the google group.
- Code quality does matter, but I'd rather encourage collaboration to make the code better than to scare you away from trying.
- Always work in a feature branch and periodically rebase this branch with master to keep in sync.
- Ensure any kind of indent or whitespace formatting is done in a separate commit _first_.
- The feature branch should be single-purpose and not include wide-reaching changes because it will be too hard to verify your changes.
- Do not do any version bumping. Bonus points if you are familiar with [semver](http://semver.org) and add features in a backwards compatible manner.
- Working on major release updates is 100% encouraged, but best to start a dialogue first since it will take time to merge in.
- **Super Bonus points for adding cucumber tests for your feature or fix.**

### Testing

We use [Cucumber](http://cukes.info) for integration tests. Please have a look at <https://github.com/ruhoh/ruhoh.rb/tree/master/features> to see how to quickly write out tests.
It should be quite fast to make new tests if you take advantage of the current [step_defs](https://github.com/ruhoh/ruhoh.rb/blob/master/features/step_defs.rb).

### Reporting Issues

Please use GitHub's issue tracker to report all issues and bugs.

If you are familiar enough with cucumber, it's best to include a failing `test.feature` file that sets up your situation and shows how the expected behavior is failing.
In this way the bug can instantly be verified, a fix can be put in and a regression test will already exist =)

### Community

- <http://ruhoh.com>
- <https://twitter.com/ruhohblog>
- <https://groups.google.com/forum/?fromgroups#!forum/ruhoh>
