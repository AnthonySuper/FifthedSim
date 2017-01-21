# FifthedSim
[![Build Status](https://travis-ci.org/AnthonySuper/FifthedSim.svg?branch=master)](https://travis-ci.org/AnthonySuper/FifthedSim)


This is a gem to simulate a game that you play with dice on a d20 system.
It is unfinished, but intends to enable a user to run simulations, or to see the overall probability of things which happen.

## Usage

### Executable

If you just want to roll dice, simply install the gem and type "diceroll".
This will bring up a Dice REPL, which has some nice functionality.
Just type a dice expression, and you will get a result:

```
> d20 + 3d6
  => 18 + (3 2 6)
  =  29
```
You can also get some info about a roll by typing `info`.
Type `help` to see all the commands.

### Dice Expressions

This gem generalizes the use of dice into *DiceExpressions*, which is an expression representing a calculation done on dice.
This expression is *lazily evaluated*, which means that it does not turn into an actual numerical value until you call `.to_i` or `.value` on it.

DiceExpressions are more powerful than simply rolling dice and doing math on the results, as we can both reuse them and do statistics on them.
This allows us to figure out a variety of useful information.

Dice expressions are almost always constructed via the `Fixnum#d` method:

```ruby
1.d(20)
```

From here, mathematical operations work as normal:

```ruby
result = (1.d(20) + 3 + 2.d(6)) / (1.d(4) * 2 * 1.d(2))
```

As mentioned earlier, we can get a numeric value from this expression:

```ruby
result.value # -> 2
```

We can also reroll this expression, to get another DiceExpression with a new value:

```ruby
result.reroll.value # -> 6
```

More interestingly, we can do statistics on this value.
We can obtain a `Distribution` of possible results for a given dice expression easily:

```ruby
distribution = result.distribution
```

Now, let's see how likely our value of 2 was.
Let's also see what percentile our value is in.

```ruby
distribution.percent_exactly(2) # -> 0.199305...
distribution.percentile_of(2) # -> 0.475694...
```

So our roll wasn't terrible, but it wasn't great as well.

#### Combinations
`DiceExpressions` are a powerful construct, because they allow combinations with arbitrary functions, while still being a `DiceExpression`.
To use an example, let's try to model the damage of a kobold's dagger attack against a player character with 12 AC.

The kobold rolls `1d20 + 4` to hit.
If he gets a 12 or higher, he does `1d4 + 2` damage to this player.
Let's model this attack:

```ruby
attack = (1.d(20) + 4).test_then do |result|
  if result < 12
    0.to_dice_expression
  else
    1.d(4) + 2
  end
end
```

This is just a `DiceExpression`, so we can get its value, and reroll it:

```ruby
attack.value # => 0, the poor guy missed
attack.reroll.value # => 3, he hit... and critfailed damage.
```

Even more interestingly, however, we can do *statistics* on it.
Let's see the chance of him doing at least one damage:

```ruby
attack.distribution.percent_greater(0) # => 0.65, 65% of doing damage
```
What about the average damage per attack?

```ruby
attack.average # => 2.925
```

As long as the block passed to `test_then` is *pure* (IE, the same input maps to the same output, regardless of anything else that happens in the program), then we can do any kind of calculation we want inside of it.
This is useful in a variety of situations.

### Simulation
FifthedSim was originally designed to simulate D&D 5e games.
Doing this is still under construction, but it's coming along nicely.

Simulation is based on *Actors*.
An Actor represents a character or NPC in the game.
Actors are defined with a nice DSL:

```ruby
actor = FifthedSim.define_actor("Bobby") do
  base_ac 10
  stats do
    str 10
    dex do
      value 18
      save_mod_bonus 5
    end
    wis 8
    cha 16
    con 14
    int 12
  end
  attack "rapier" do
    to_hit 5
    damage do
      piercing 1.d(6)
    end
  end
end
```

Construction based on YAML or JSON is still a work in progress.
Actors are intended to be used to simulate battles.
This is currently a work in progress, although simulating individual attacks and such *does* currently work.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fifthed_sim'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fifthed_sim

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/anthonysuper/fifthedsim.
Please see the [HelpWanted.md](HelpWanted.md) file for specific patches we are looking for.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

