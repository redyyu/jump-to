# Jump To Menu

A Mod for Project Zomboid.

there no native jump action in Vanilla.
with this Mod, player can trigger jump action by context menu.
right click on the ground, there is `Jump To` option on menu now.
*just like `Walk To` option.*

Can also trigger by Key `Crouch` (for switch to sneaking),
when Mod Sandbox `KeyPressToJumpEnabled` set to true.
I don't want add KEY binds to Vanilla, `Crouch` is best option, it's looks like prepare to jump.

For Joypad, they might diffcult to using context menu.
try press `RBumper` button
*untested might not work.*

The square of selection is only for the direction，How far you can jump is depends on physics and body condition.
Jump farther during run and sprint, closer when heavy load.
Fitness, Sprinting, Obesity, Overweight, Fatigue, Endurance, Sickness, Heavy Load, Injured or Pain can all affect to jump.

Jump will effect by inertia (native physics engine).

you won't jump that often like Mario.
you won't jump over zombies.
you won't jump into river. (but you can jump out, if you already stuck in middle of river)

Use when you need
jump over between safehouse brige.
accidentally falling in to lake or river. 
(I did once, character stack in one square, blocked by any direction, 
and no meterial to build floor. it's Dead already!!)

*Remember, you can running or sprinting a while, then select the square, 
can go farther. just like real world.*


The original idea is from another Mod call `Jump`. Very good job!
this Mod give so much more action movement to this game.

But I feel a little bit too powerful.
game is too easy when use those too often,
seems this game is not design to have those amazing movements.
*it's not Tomb Rider anyway*

Also I don't like to bind more KEY for anything, 
there is so many keys already.

That's why I deiced to make another one. 

Credit must go to Tchernobill *the author of `Jump`*.

I did learn much more from Tchernobill's MOD.
very good coding style and pertty logic.
Must be thanks.

even I'm not use those code at last.

I skip the distance param, use maxTime in timedAction to control how far to jump.
there is no need destX or destY anymore.

Vanilla's physics engine will taking care it by inertia.
jump when running or sprinting can go farther as native physics.

only need keep character not falling while the jump animation is playing.

also keep the original collisions,
it's better than check square isblocked by lua every frames.
that may fail in extreme cases. 
etc,. jump around a car, with a coincidental distance and angle can pass through.
