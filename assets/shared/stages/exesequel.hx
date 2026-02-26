import objects.BGSprite;
import flixel.effects.FlxFlicker;
import objects.HealthIcon;


var starmanPOW;
var blackBarThingie;
var platform2;

var iconGF;

var eventTweens = [];
var eventTimers = [];
var extraTween = [];
function onCreate(){
    iconGF = new HealthIcon('terence', false);


    game.addCharacterToList('nugget', 2);
    game.addCharacterToList('mariohorror-melt', 1);

    var sky:BGSprite = new BGSprite('EXE1/starman/SS_sky', -1100, -600, 0.1, 0.1);
    sky.antialiasing = ClientPrefs.data.antialiasing;
    addBehindGF(sky);

    var castillo:BGSprite = new BGSprite('EXE1/starman/SS_castle', -1125, -600, 0.2, 0.2);
    castillo.antialiasing = ClientPrefs.data.antialiasing;
    addBehindGF(castillo);

    var fireL:BGSprite = new BGSprite('EXE1/starman/Starman_BG_Fire_Assets_star', -1400, -850, 0.4, 0.4, ['fire anim effects'], true);
    fireL.antialiasing = ClientPrefs.data.antialiasing;
    addBehindGF(fireL);

    var fireR:BGSprite = new BGSprite('EXE1/starman/Starman_BG_Fire_Assets_star', 700, -850, 0.4, 0.4, ['fire anim effects'], true);
    fireR.animation.addByIndices('delay', 'fire anim effects', [8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7], "", 24, true);
    fireR.antialiasing = ClientPrefs.data.antialiasing;
    fireR.flipX = true;
    addBehindGF(fireR);
    fireR.animation.play('delay');

    var platform0:BGSprite = new BGSprite('EXE1/starman/SS_farplatforms', -950, -600, 0.55, 0.55);
    platform0.antialiasing = ClientPrefs.data.antialiasing;
    addBehindGF(platform0);

    starmanPOW = new BGSprite('EXE1/starman/SS_POWblock', 835, 610, 0.55, 0.55);
    starmanPOW.antialiasing = ClientPrefs.data.antialiasing;
    addBehindGF(starmanPOW);

    var platform1:BGSprite = new BGSprite('EXE1/starman/SS_midplatforms', -850, -600, 0.65, 0.65);
    platform1.antialiasing = ClientPrefs.data.antialiasing;
    addBehindGF(platform1);

    var floor:BGSprite = new BGSprite('EXE1/starman/SS_floor', -750, -600, 1, 1);
    floor.antialiasing = ClientPrefs.data.antialiasing;
    addBehindDad(floor);

    blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
    blackBarThingie.scrollFactor.set(0, 0);
    blackBarThingie.visible = false;
    addBehindDad(blackBarThingie);

    platform2 = new BGSprite('EXE1/starman/SS_foreground', -1100, -600, 1.3, 1.3);
    platform2.antialiasing = ClientPrefs.data.antialiasing;
    add(platform2);


    return;
}

function onCreatePost(){
    for (n in unspawnNotes){
        if (n.noteType == 'Yoshi Note') 
        {
            n.noAnimation = true;
            n.visible = false;
        }
    }
}

function onUpdate(){
    iconGF.x = iconP2.x - 75;
    iconGF.scale.set(iconP2.scale.x - 0.1, iconP2.scale.y - 0.1);

    iconGF.animation.curAnim.curFrame = iconP2.animation.curAnim.curFrame;
    return;
}

function onEvent(n,v1,v2){
    if (n == 'Triggers Universal') {
        var trigger:Float = Std.parseFloat(v1);
        var trigger2:Float = Std.parseFloat(v2);
        if (Math.isNaN(trigger))
            trigger = 0;
        if (Math.isNaN(trigger2))
            trigger2 = 0;

        switch(trigger)
        {
            case 2:
                //132
                game.uiGroup.add(iconGF);
                iconGF.y = (!ClientPrefs.data.downScroll ? 820 : -150);
                eventTweens.push(FlxTween.tween(iconGF, {y: iconP2.y - (!ClientPrefs.data.downScroll ? 35 : -25)}, 3, {ease: FlxEase.expoOut}));
                eventTweens.push(FlxTween.tween(gfGroup, {y: 0}, 3, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween)
                    {
                        extraTween.push(FlxTween.tween(gfGroup, {y: gfGroup.y - 80}, 2, {ease: FlxEase.quadInOut, type: 4}));
                    }}));
                extraTween.push(FlxTween.tween(gfGroup, {x: gfGroup.x - 100}, 3, {ease: FlxEase.quadInOut, type: 4}));
            case 4:
                //256
                var dadx:Float = dadGroup.x;
                var dady:Float = dadGroup.y;
                for (tween in extraTween)
                    {
                        tween.cancel();
                    }
                extraTween.push(FlxTween.tween(iconGF, {y: (!ClientPrefs.data.downScroll ? 820 : -150)}, 1.5, {ease: FlxEase.expoIn}));
                extraTween.push(FlxTween.tween(gfGroup, {x: 3500}, 1.5, {ease: FlxEase.quadInOut}));
                extraTween.push(FlxTween.tween(gfGroup, {y: -400}, 1.5, {ease: FlxEase.cubeIn, onComplete: function(twn:FlxTween)
                    {
                        game.triggerEvent('Change Character', '2', 'nugget');
                        gfGroup.scrollFactor.set(0.55, 0.55);
                        game.triggerEvent('Play Animation', 'appear', 'gf');
                        gfGroup.x = 685;
                        gfGroup.y = -1200;

                        eventTimers.push(new FlxTimer().start(1.24, function(tmr:FlxTimer)
                            {
                               gfGroup.y = 20;
                               game.triggerEvent('Play Animation', 'appear', 'gf');

                               game.triggerEvent('Screen Shake','0.8, 0.02','');
                               game.triggerEvent('Play Animation', 'xd', 'dad');
                               starmanPOW.visible = false;
                               extraTween.push(FlxTween.tween(dadGroup, {y: 1500}, 0.6, {ease:FlxEase.quadIn, onComplete: function(twn:FlxTween)
                                   {
                                       dadGroup.x = dadx;
                                       dadGroup.y = dady;
                                       game.triggerEvent('Change Character', '1', 'anus');
                                       dad.visible = false;
                                       iconGF.changeIcon('nug');
                                       iconGF.y = iconP2.y - (!ClientPrefs.data.downScroll ? 35 : -25);
                                   }}));
                            }));
                    }}));
            case 6:
                dad.visible = true;
            case 69:
                dad.visible = false;
            case 11:
                //396
                eventTimers.push(new FlxTimer().start(1.875, function(tmr:FlxTimer)
                    {    
                        extraTween.push(FlxTween.tween(iconGF, {alpha: 0}, 0.75, {ease: FlxEase.expoIn}));
                        eventTimers.push(new FlxTimer().start(2.0833, function(tmr:FlxTimer)
                            {
                                gfGroup.visible = false;
                            }));
                    }));
                // starmanPOW.visible = false;
            case 12:
                //404
                // BF_ZOOM = 0.8;
                // BF_CAM_X = 1550;
                // defaultCamZoom = 0.8;
                dad.visible = true;
                game.triggerEvent('Change Character', '1', 'mariohorror-melt');
                game.triggerEvent('Play Animation', 'jump', 'dad');
                dad.x -= 800;
                dad.y += 1200;
                eventTweens.push(FlxTween.tween(dad, {x: dad.x + 800}, .95, {startDelay: 0.8, ease: FlxEase.linear}));
                eventTweens.push(FlxTween.tween(dad, {y: dad.y - 2200}, 0.6, {startDelay: 0.8, ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
                    {
                        game.triggerEvent('Play Animation', 'fall', 'dad');
                        eventTweens.push(FlxTween.tween(dad, {y: dad.y + 1000}, 0.35, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
                            {
                                game.triggerEvent('Play Animation', 'singDOWN', 'dad');           
                            }}));
                    }}));
            case 13:
                //406 this does nothing lololol
                // BF_ZOOM = 0.9;
                // BF_CAM_X = 1650;
                // defaultCamZoom = 0.9;
            case 16:
                extraTween.push(FlxTween.tween(dadGroup, {alpha: 0}, 2));
                extraTween.push(FlxTween.tween(camHUD, 	{alpha: 0}, 2));

                //3,875
            case 17:
                //514
                
                boyfriendGroup.visible = false;
                blackBarThingie.visible = true;
                platform2.visible = false;
                FlxG.camera.flash(FlxColor.RED, 0.5);
                game.triggerEvent('Screen Shake','3.8, 0.01','');
        }
    }
}

function opponentNoteHit(note){
    if (note.noteType == 'GF Duet' || note.noteType == 'Yoshi Note'){
        gf.playAnim(game.singAnimations[note.noteData], true);
        gf.holdTimer = 0;
    }
}