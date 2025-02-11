final NOTE_COUNT:Int = 8;
var state = PlayState.instance;

var receptorMoveMod = {
    value: 0,
    topY: 50,
    bottomY: FlxG.height - 150
};

function onCreate(){}

function lerp(a:Float, b:Float, c:Float)
    return a + (b - a) * c;

function predictReceptorMoveModPos(time:Float)
{
    var sectionCrochet:Float = (Conductor.crochet * 4);

    var timeMod:Float = (time % (sectionCrochet * 2)) / sectionCrochet;
    var yPos:Float = lerp(50, (timeMod > 1) ? lerp(receptorMoveMod.bottomY, receptorMoveMod.topY, timeMod % 1) : lerp(receptorMoveMod.topY, receptorMoveMod.bottomY, timeMod % 1), receptorMoveMod.value);

    return yPos;
}

function onUpdate(elapsed:Float)
{
    if (curBeat >= 1168 && curBeat < 1198)
    {
        for (note in state.strumLineNotes) {
            note.x += Math.cos(Conductor.songPosition / Conductor.stepCrochet / 4 + note.ID) * (elapsed/(1/60));
            note.y += Math.sin(Conductor.songPosition / Conductor.stepCrochet / 4 + note.ID) * (elapsed/(1/60));
        }
    }
    
    if (curBeat >= 208 && curBeat < 215 || curBeat >= 224 && curBeat < 231 || curBeat >= 240 && curBeat < 247 || curBeat >= 256 && curBeat < 263)
        state.songSpeed += Math.sin(Conductor.songPosition / Conductor.stepCrochet) * 0.055;
}

function onUpdatePost(elapsed:Float)
{
    var songTime = Conductor.songPosition;

    var sectionCrochet:Float = (Conductor.crochet * 4);

    if (receptorMoveMod.value > 0)
    {
        var receptorY:Float = predictReceptorMoveModPos(songTime);

        for (i in 0...NOTE_COUNT)
            game.strumLineNotes.members[i].y = receptorY;

        for (note in game.notes)
            note.y = lerp(note.y, predictReceptorMoveModPos(note.strumTime), receptorMoveMod.value);
    }
}
function onSpawnNote(note)
{
    if (receptorMoveMod.value > 0.25)
    {
        note.multAlpha = 0;
        FlxTween.tween(note, {multAlpha: 1}, (Conductor.crochet / 2000));
    }
}

function onBeatHit()
{
    var curBeat:Int = game.curBeat;

    if (curBeat == 215 || curBeat == 231 || curBeat == 247 || curBeat == 263)
        state.songSpeed = PlayState.SONG.speed;

    if (curBeat == 952)
        FlxTween.tween(receptorMoveMod, {value: 1}, (Conductor.crochet / 1000) * 4, {ease: FlxEase.expoOut});

    if (curBeat == 966)
        FlxTween.tween(receptorMoveMod, {value: 0}, 1, {ease: FlxEase.quadOut});
}