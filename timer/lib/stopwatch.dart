import 'package:flutter/material.dart';

class StopwatchFunctions{
  //---Command Functions
  Function start;
  Function stop;
  Function setMaxTime;
  Function reset;
  //---Information Functions
  Function getMaxTime;
  Function getTimePassed;
  Function getTimeLeft;
  Function isRunning;
}

class Stopwatch extends StatefulWidget {

  final StopwatchFunctions functions = new StopwatchFunctions();

  @override
  _StopwatchState createState() => _StopwatchState();
}

class _StopwatchState extends State<Stopwatch> with SingleTickerProviderStateMixin{

  AnimationController stopwatch;
  //REQUIRED because our "stopwatch.duration" will not always be what we set it to originally because technically pausing (or stopping) a stopwatch stops it and sets it all over again
  Duration maxStopwatchTime; //ONLY SET in the set method [no exceptions]
  //REQUIRED because our stopwatch is paused (or stopped) it you can no longer access "stopwatch.lastElapsedDuration"
  Duration lastElapsedDurationNOANIM; //ONLY NOT NULL when our timer is not animating

  linkFunctions(){
    var w = widget.functions;
    //---Command Functions
    w.start = start;
    w.stop = stop;
    w.setMaxTime = setMaxTime;
    w.reset = reset;
    //---Information Functions
    w.getMaxTime = getMaxTime;
    w.getTimePassed = getTimePassed;
    w.isRunning = isRunning;
  }

  @override
  void initState() {
    super.initState();
    stopwatch = new AnimationController(
      vsync: this,
    );
    maxStopwatchTime = new Duration(days: 365);
    lastElapsedDurationNOANIM = null;

    linkFunctions();
  }

  @override
  Widget build(BuildContext context) {
    linkFunctions();

    return new Container(
      child: new Text(""),
    );
  }

  @override
  void dispose(){
    stopwatch.dispose();
    super.dispose();
  }

  /*
  There are 2 main states the timer can be in... And multiple sub states... And each has its own signature
  - - - 0. Both
  * original Time, time Left (will be correct as long time passed is right)
  - - - 1. Running (timer.isAnimating, timeLeft = null)
  * !timer.isCompleted, timePassed = timer.lastElapsedDuration + (originalTime-timer.duration) [RUNNING]
  - - - 2. Not running (!timer.isAnimating, timeLeft != null)
  * timer.isCompleted, lastElapsedDurationNOANIM = null, timePassed = originalTime [DONE]
  * !timer.isCompleted, lastElapsedDurationNOANIM = null, timePassed = 0 [NEVER STARTED]
  * !timer.isCompleted, lastElapsedDurationNOANIM != null, timePassed = originalTime - lastElapsedDurationNOANIM [PAUSED]
  */

  //-------------------------COMMAND FUNCTIONS-------------------------

  //we can either start a brand new timer, or start a timer from its previous location
  start(){
    if(stopwatch.isAnimating == false){
      stopwatch.reset(); //reset the timer to prevent odd behavior
      if(lastElapsedDurationNOANIM == null) stopwatch.duration = maxStopwatchTime; //this is the first time the timer has been started
      else stopwatch.duration = lastElapsedDurationNOANIM; //the timer is being unpaused
      lastElapsedDurationNOANIM = null;
      stopwatch.forward();
    }
  }

  stop(){
    if(stopwatch.isAnimating == true){
      lastElapsedDurationNOANIM = _getTimeLeft();
      stopwatch.stop();
    }
  }

  setMaxTime(Duration newDuration){

    bool wasRunning = stopwatch.isAnimating; //save whether or not the timer was running
    stop(); //if the timer is running stop it
    stopwatch.reset(); //reset the timer to prevent odd behavior

    //set the new timer values
    maxStopwatchTime = newDuration;
    lastElapsedDurationNOANIM = null;

    //start the timer if it was running at first
    if(wasRunning) start();
  }

  reset() => setMaxTime(maxStopwatchTime);

  //-------------------------INFORMATION FUNCTIONS-------------------------

  Duration getMaxTime() => maxStopwatchTime;

  Duration getTimePassed(){
    if(stopwatch.isAnimating) //the timer is playing
      return stopwatch.lastElapsedDuration + (maxStopwatchTime-stopwatch.duration);
    else{
      if(lastElapsedDurationNOANIM != null) //the timer is paused
        return maxStopwatchTime - lastElapsedDurationNOANIM;
      else{ //the timer is stopped
        if(stopwatch.isCompleted)
          return maxStopwatchTime; //the timer finished on its own (Show all 0s on screen)
        else
          return Duration.zero; //the timer never began (show original time on screen)
      }
    }
  }

  Duration _getTimeLeft() => getMaxTime() - getTimePassed();

  isRunning() => stopwatch.isAnimating;
}
