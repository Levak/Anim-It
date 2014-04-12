Anim-It
=======

Animation Framework for TI-Nspire Lua

## What is it ?

Anim-It is an Animation API for TI-Nspire Lua that let you animate properties of objects over
time by simply call `object:Animate({property:target_value, ...}, milliseconds, callback)`.
If you're used to jQuery, you'll see in Anim-It some identical patterns.

## How does it work ?

Anim-It is composed of 2 main parts :

* The **Scheduler**, located in `timer.lua`, gives a quantum to each active
  animation. It thus needs to be called in the event `on.timer` with `timer.update()`.

* The **Object** base class, located in `object.lua`, whom each animated
  object needs to inherit from.

## How I can use it ?

Follow these simple rules :

1. Add [object.lua](src/object.lua) and [timer.lua](src/timer.lua) to your project or sources.

2. In your event `on.timer`, add a call to `timer.update()`. It is also
   recommended to call `platform.window:invalidate()`. By default,
   `timer.update` stops the Lua timer ; If you don't wan't that, use
   `timer.update(true)`.

3. Make your classes you want to animate **inherit from `Object`** :
```
AnimatedRectangle = class(Object)
```

4. Call Object constructor with the properties you wish to animate :
```
function AnimatedRectangle:init(x, y, w, h)
         Object.init(self, {x = x, y = y})
         self.w, self.h = w, h
end
```

5. Animate it !
```
local my = AnimatedRectangle(10, 20, 30, 40)
my:Animate({x = 20}, 100)
  :Animate({x = 200, y = 200}, 100)
  :Delay(300)
  :Animate({x = 10, y = 20}, 200,
    function(self)
      print("The end !")
    end)
```

## Projects that uses Anim-It :

* [EEPro-for-Nspire](https://github.com/adriweb/EEPro-for-Nspire)
* [2048](http://ti-pla.net/a42651)
