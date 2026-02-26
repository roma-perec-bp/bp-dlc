var state = PlayState.instance;

function onCreate(){}

function onUpdate(elapsed:Float)
{
    if (curBeat >= 208 && curBeat < 215 || curBeat >= 224 && curBeat < 231 || curBeat >= 240 && curBeat < 247 || curBeat >= 256 && curBeat < 263)
        state.songSpeed += Math.sin(Conductor.songPosition / Conductor.stepCrochet) * 0.055;
}

function onBeatHit()
{
    var curBeat:Int = game.curBeat;

    if (curBeat == 215 || curBeat == 231 || curBeat == 247 || curBeat == 263)
        state.songSpeed = PlayState.SONG.speed;
}