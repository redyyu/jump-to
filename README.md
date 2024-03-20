# Jump To Menu

A Mod for Project Zomboid.

there no native jump action in Vanilla.
with this Mod, player can trigger jump action by context menu.
right click on the ground, there is `Jump To` option on menu now.
*just like `Walk To` option.*

For Joypad, they might diffcult to using context menu.
try press `RBumper` button
*untested might not work.*

The square of selection is only for the direction of jump. 
The distance of jump is base on Fitness and Sprinting Preks. 
Jump farther during run and sprint, closer when heavy load.
Obesity, Overweight, Fatigue, Endurance or Pain can all affect the distance.

because jump is trigger by menu option,
you can't jump that often like Mario.
also won't jump over zombies.
only use when you need

like jump over between safehouse brige.
accidentally falling in to lake or river. 
(I did once, player stack in one square, blocked by any direction, 
and no meterial to build floor. it's Dead already!!)

*Remember, you can still running or sprinting after the selection square showing up, 
that will increase the jump distance.*


The original idea is from another Mod call `Jump`. Very good job!
this Mod give so much more action movement to this game.

But I feel little bit too powerful with such actions.
game is too easy when use those too often,
seems this game is not design to have those amazing movements.
*unlike Tomb Rider anyway*

Also I don't like to bind more KEY for anything, 
there is so many keys already.

That's why I deiced to make another one. 

Credit must go to Tchernobill *the author of `Jump`*.

I did learn much more from Tchernobill's MOD.
even not use that at last.

I use maxTime of timedAction to decide how far to jump.
the time should be closed with animation time, otherwise will looks strange.

there is no need destX or destY anymore.
player is actually moving one or more square when jump animtion is playing.
pertty sure it is because event or state change by Vanilla.
and it's can be far when running or sprinting as native.

only need keep character not falling and play a jump animation.

why not? it's moving away.

also can use original collision,
it's not good to check blocked or not by lua.
may fail in extreme cases. 
etc,. jump around a car, with a coincidental distance and angle can pass through.
