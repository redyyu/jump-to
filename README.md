# Refined Character Actions

A Mod for Project Zomboid.

Make charactor can Jump, Swimming, Sit for rest.

=============================================================

## Usage:


### Jump

Activated it from context menu. Select a direction to jump. 
Jump always cross one square, when starts standing. Jump while moving, how far you can jump is depends on physics and body condition. Jump farther during run or sprint, higher rank of Fitness and Sprinting can increase jump range. Jump closer when Obese, Overweight, Overrun, Tired, Sick, Heavy Load, Injured or Pain can all affect to jump. Jump always cross one square from standing. Jump while moving, will go farther during run or sprint, higher rank of Fitness and Sprinting can increase jump range. Jump closer when Obese, Overweight, Overrun, Tired, Sick, Heavy Load, Injured or Pain can all affect to jump.

### Swimming

Click on water when nearby, there is Option for into the water.
after into the water, the character can swimming around, until reach the land.

Shoes will be unequip before swimming start. (feet won't be hurts during swimming.)

Player can't do anything else during swimming, otherwise too much animate work to do.

All the clothes you're wearing wet quickly.
Happiness will growing, Boredom will goes away. But Endurance will consume quickly. 

Character could die middle of river.
Since player can do anything else durning swimming, you won't get anything back.
So don't swim to far....

For Joypad, not tested. try press `RBumper` button when close water, not in running or sprinting.

*have done in or out water animation yet. leave that for future update.*


### Sit and Rest

The vanilla `Rest` will be replace by `Rest on <chair name>` option.
*or `Sit on <chair name>` when `Endurance` is full.*

You can sit on Chair, Couch, Funton, Bench, Church, Stool or Seat.
Character's `Endurance` will recovery just like `Rest`.

When the `Endurance` is fully restored, character will keep sit on the chair, until canceled.

Character won't be `Strafe` during sitting, so becareful when zombies around.

Character will move the front of the Chair than sit.
Sometime, the front of chair might not reachable. In that case, the action will brake.

you can still use the vanilla `Rest` by turn it ON from Mod's sandbox.
=============================================================

## Details


### Jump

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

Jump will effect by inertia (native physics engine).

you won't jump that often like Mario.
you won't jump over zombies.
you won't jump into river. 
you can get free you ware stuck in some square, like the one 4 square bed just build.

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


### Swimming

Since make full animSet for Swimming is too much work todo. 
*(Almost every player animate in vanilla must have a swimming version)*

Swimming action actually use maskingright animset. 
The swimming animation is move the character `anim_X` to lower the ground.
And half body in water is masked by a hidden Clothing `SwimmingBodyMASK`.
*This clothingItem have masks to cover every thing must in water.*
*And it is a shoes, will prevent feet be hurts. swimming is walking play a swimming animation actually*

On the other hand use a `SwimmingRightHandHackingItem` with `ReplaceInPrimaryHand = none swimming,`
to trigger `maskingright` state ON. 
*This Item must have StaticModel, otherwise will not trigger the state. So there is transparent cube in models_X*

both those two items for hacking is not `DisplayName`, that's how to make it hidden form inventory.

Also clear all other timedActoins durning Swimming, to prevent unwanted animation play.


### Sit for Rest

No need setNoClip for Sit on Chair. the animSet have Offset version.
if the chair is solid (blocked way) then Character will move to the front of square, 
than player a `TimedAction` set the animSet `SitOnChairOffset`.
if the chair is free square, just move on the chair, than play animSet `SitOnChair`.
otherwise, the chair might not reachable, the action won't start.

**A strange problem with AnimSets**
in some case native `<m_Conditions>` with custom `<m_Conditions>` 
will jam the timedAction animation play for no reason.
maybe is the `sitonground` state with `action/reading` only need change upper body.
but if add custom conditions, the animation still can play.
but unable to use TimedAction now. unless remove one of the conditions,
no matter which one. in my case, I remove the native one,
because use custom one is good enough to trigger it.

it's not logic, don't understand what's the problem yet.
might be animate buggey? because the X?


```
<animNode>
	<m_Name>sit_action</m_Name>
	<m_AnimName>Bob_SitGround_ActionIdle</m_AnimName>
	<m_deferredBoneAxis>Y</m_deferredBoneAxis>
	<m_SyncTrackingEnabled>false</m_SyncTrackingEnabled>
	<m_SpeedScale>0.30</m_SpeedScale>
	<m_BlendTime>0.30</m_BlendTime>
	<m_Conditions>  <--- THIS --->
		<m_Name>SitGroundAnim</m_Name>
		<m_Type>STRING</m_Type>
		<m_StringValue>Idle</m_StringValue>
	</m_Conditions>
    <m_Conditions>  <--- WITH THIS CUSTOM --->
        <m_Name>SitChair</m_Name>
        <m_Type>STRING</m_Type>
        <m_StringValue>normal</m_StringValue>
    </m_Conditions>
	<m_Conditions>
		<m_Name>hasTimedActions</m_Name>
		<m_Type>BOOL</m_Type>
		<m_BoolValue>true</m_BoolValue>
	</m_Conditions>
	<m_Transitions>
		<m_Target>sit_loop</m_Target>
		<m_AnimName>Bob_SitGround_ActionToSitIdle</m_AnimName>
		<m_speedScale>1</m_speedScale>
	</m_Transitions>
</animNode>
```