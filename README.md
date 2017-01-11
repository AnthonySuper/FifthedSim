# FifthedSim
[![Build Status](https://travis-ci.org/AnthonySuper/FifthedSim.svg?branch=master)](https://travis-ci.org/AnthonySuper/FifthedSim)


This is a gem to simulate a game that you play with dice on a d20 system.
It is unfinished, but intends to enable a user to run simulations, or to see the overall probability of things which happen.

## Dice

This gem generalizes the use of dice into *DiceExpressions*, which is an expression representing a calculation done on dice.
These expressions have *values*, which represent one run of this expression.
They also come with a *distribution*, which is a probabilistic distribution of the possible values of the expression.
Perhaps an example is in order.
Let's say that a character does `3d6 + 2d8 + 5` damage.
We can express this easily:

```ruby
attack = 3.d(6) + 2.d(8) + 5
```

Now, let's analyze this value. First, let's see what we rolled:

```ruby
attack.value
# => 19
```

Hm. Is that a good roll?

```ruby
attack.above_average?
# => false
```

Guess not.
How close were we to being average?

```ruby
attack.difference_from_average
# => -5.5
```

That's fairly large.
Let's see what percentile we were in:

```ruby
attack.percentile
# => 0.13179
```

Ouch.
That's pretty bad.


We can do a wide variety of other things with this roll, including combining it with other rolls, as well as statistical averaging.
More documentation is yet to come.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fifthed_sim'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fifthed_sim

## Usage

See the rdoc for now.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/anthonysuper/fifthedsim.
Please see the [HelpWanted.md](HelpWanted.md) file for specific patches we are looking for.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

