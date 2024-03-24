# Jump To Menu

A Mod for Project Zomboid.

there no native jump action in Vanilla.
with this Mod, player can trigger jump action by context menu.
right click on the ground, there is `Jump To` option on menu now.
*just like `Walk To` option.*

Can also trigger by Key `Crouch` (Sneak),
when Mod Sandbox `KeyPressToJumpEnabled` set to true.
Since  There is no plan to add new keybindings to to Vanilla yet,
`Crouch` is best option. ( it's looks like prepare to jump)

*Keep in mind, too many keys pressed at sametime, might cause `Keyboard conflict`. It is uncertain which keys are conflicting, that depending on the keyboard you use (happen in any other games).*

For Joypad, they might diffcult to using context menu.
try press `RBumper` button
*untested might not work.*

=============================================================

Usage:

Activated it from context menu. Select a direction to jump. 
Jump always cross one square, when starts standing. Jump while moving, how far you can jump is depends on physics and body condition. Jump farther during run or sprint, higher rank of Fitness and Sprinting can increase jump range. Jump closer when Obese, Overweight, Overrun, Tired, Sick, Heavy Load, Injured or Pain can all affect to jump. Jump always cross one square from standing. Jump while moving, will go farther during run or sprint, higher rank of Fitness and Sprinting can increase jump range. Jump closer when Obese, Overweight, Overrun, Tired, Sick, Heavy Load, Injured or Pain can all affect to jump.

=============================================================

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




# Develop Tips


## AnimSet

I did try to make anim set for swimming. the major problem is the gap animation by turnning.
even stop sneak or running or aiming... still lot work to do.
finall the turning animate is fine now.

but another problem is kill all the works.
movement animset is play, but character won't moving.
did lot more try. never make fbx animtion to moving.
I guess is something missing in fbx, the character moving is by the animation X file.
not by java or lua code. which is don't know yet.

plan B is use maskingright animset. just like I did the Bike and Trolley mod.
and I did tested its work.

Just like the body in water effect is use item clothing to hack the mask too,
I have to hack another shadow item keep equipment on right hand.

not good idea, but the only way for now.