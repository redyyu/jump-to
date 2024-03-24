# Develop Tips

Those `AnimSets` is for prevent unwanted animation play during Swimming.

I did try to make anim set for swimming. 
There is too much work todo for full fill every animation between on floor or in water.
almost every animation must have swimming version. 
Even force to stop sneak, running, sprinting, aiming... still lot work to do.
so .... GIVE UP....

on the other hand, whatever `movement` state AnimSet is play, 
the character still won't moving.
I did lot more test. I guess that's because I using fbx animation.
I guess the character **moving** is by `X` file animation, not by java or lua code. 
probably something missing in fbx, don't know what is missing yet.

since there is no document for this, plan B comes up.

**Plan B**
Plan B is use maskingright animset. just like I did the Bike and Trolley mod.
and it's work fine.

But, I have to use a *hack item* to trigger the `maskingright` on.
also I had to prevent player to equip, unequip, attach, unattach, eat, smoke, transfer items, bandging, reading map ....
all those action will break the swimming animation.
(or full fill all those animation for swimming as well.... lot more work to do.) 

So, I clear all timedActoins durning Swimming, player won't do anything else.
Also `Sneaking` and `Sprinting` will disabled.
perfect safe for swimming now!

best idea for now.