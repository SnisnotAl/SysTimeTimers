# SysTimeTimers
Alternative to the timer.* library in Garry's Mod

originally created to work during server timeout (on the client) as we use SysTime not CurTime

Ensure `sv_hibernate_think` is set to `1` or the timers will not work when your server is empty!
If you don't want to, you can use `stt_ignore_hibernation_warning 1`, to diable the warning about hibernation on timer creation!

## Example Usage

```lua
systimetimers.Create("example", 1, 0, function()
  print("Hello World!")
end)
```

(This will create a timer named `example` with a delay of `1` seconds and will repeat `infinite` times
The repeat amount, if less than 0, will be infinite.

The usage is almost identical to https://wiki.facepunch.com/gmod/timer
but just replace timer with systimetimers

### Function list
```lua
Functions:
      - systimetimers.Adjust( string timerName, number timerDelay, number timerRepeat, function timerFunction, boolean pauseOnRun )
      - .Check() - Does nothing, just like timer.Check ;(
      - .Create( string timerName, number timerDelay, number timerRepeat, function timerFunction, boolean pauseOnRun )
      - .Destroy( string timerName )
      - .Exists( string timerName )
      - .GetQueue() - This contains all the timers with all their statuses and whatnot, don't modify these values unless you know what you're doing!
      - .Pause( string timerName )
      - .Remove( string timerName )
      - .RepsLeft( string timerName )
      - .Resume( string timerName )
      - .Simple( string timerName, function timerFunction )
      - .Start( string timerName )
      - .Stop( string timerName )
      - .TimeLeft( string timerName )
      - .Toggle( string timerName )
```
