# Help Wanted

This file contains a list of improvements we desire for this gem.
If you can help out, feel free to make a pull request on the [Github](https://github.com/AnthonySuper/FifthedSim)


## Top and Bottom Nodes
Some dice games require that you roll a certain amount of dice, and take the top or bottom rolls.
For example, to apply *disadvantage* in D&D, you roll 2d20 and take the lowest D20.

For the case of choosing between two dice calculations, we use the `.or_less` and `.or_greater` methods.
Unfortunately, these are not the only types of top and bottom calculations used in games.
Rolling a stat in D&D, for example, is `4d6 (drop lowest)`.

Finding a generic distribution for this is, as it turns out, hard to do efficiently.
The simple way is to take all possible combinations of rolls, drop the lowest, count the remaining values, and create a distribution from this information.
Unfortunately, the number of combinations of rolls is `dice_type^dice_number`, which is an exponential calculation.

If you know of a better formula, we'd love to hear about it.
You can either [open an issue](https://github.com/AnthonySuper/FifthedSim/issues/new) describing it, or create a pull request yourself.

If there does not exist a better formula, we'd also love to hear about it.
You can [open an issue](https://github.com/AnthonySuper/FifthedSim/issues/new) with a link to a proof that this operation cannot be done any quicker, and we will implement the brute-force solution.
