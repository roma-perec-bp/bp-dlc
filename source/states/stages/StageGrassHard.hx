package states.stages;

import states.stages.objects.*;
import substates.GameOverSubstate;
import objects.Character;

class StageGrassHard extends BaseStage
{
	var army1:FlxTypedGroup<ZombieDancers>;
	var army2:FlxTypedGroup<ZombieDancers>;
	var army3:FlxTypedGroup<ZombieDancers>;

	var solidColBeh:FlxSprite;
	var vin:FlxSprite;

	var vignetter:Bool;
	override function create()
	{
		var _song = PlayState.SONG;
		if(_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pico';
		if(_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) GameOverSubstate.loopSoundName = 'gameOver-pico';
		if(_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) GameOverSubstate.endSoundName = 'gameOverEnd-pico';
		if(_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) GameOverSubstate.characterName = 'pico-hard-dead';

		var sky:BGSprite = new BGSprite('sky-hard', -647, -544, 0.3, 0.3);
		add(sky);

		var bg:BGSprite = new BGSprite('bg-hard', -980, -300, 1, 1);
		add(bg);

		if (!ClientPrefs.data.lowQuality)
		{
			army1 = new FlxTypedGroup<ZombieDancers>();
			army2 = new FlxTypedGroup<ZombieDancers>();
			army3 = new FlxTypedGroup<ZombieDancers>();
	
			add(army3);
			add(army2);
			add(army1);
	
			for (i in 0...6)
			{
				army3.add(new ZombieDancers((i * 250) + FlxG.random.float(-3430, -3400), -142));
			}
	
			for (i in 0...6)
			{
				army2.add(new ZombieDancers((i * 250) + FlxG.random.float(-3330, -3300), -92));
			}
	
			for (i in 0...6)
			{
				army1.add(new ZombieDancers((i * 250) + FlxG.random.float(-3530, -3500), -42));
			}
		}
	}

	override function createPost()
    {
		solidColBeh = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		solidColBeh.scale.set(5,5);
		solidColBeh.alpha = 0.001;
		addBehindGF(solidColBeh);

		vin = new FlxSprite().loadGraphic(Paths.image('RedVG'));
		vin.updateHitbox();
		vin.setGraphicSize(FlxG.width, FlxG.height);
		vin.screenCenter();
		vin.cameras = [camHudBehind];
		vin.alpha = 0.0001;
		add(vin);

		camHUD.alpha = 0.0001;
	}

	var danceVG:Bool = false;
	override function beatHit()
	{
		if (!ClientPrefs.data.lowQuality)
		{
			army1.forEach(function(spr:ZombieDancers)
			{
				spr.dance();
			});
		
			army2.forEach(function(spr:ZombieDancers)
			{
				spr.dance();
			});
		
			army3.forEach(function(spr:ZombieDancers)
			{
				spr.dance();
			});
		}

		if (vignetter)
		{
			danceVG = !danceVG;

			if(danceVG)
				FlxTween.tween(vin, {alpha: 0.6}, Conductor.stepCrochet * 4 / 1000, {ease: FlxEase.expoOut});
			else
				FlxTween.tween(vin, {alpha: 0.0001}, Conductor.stepCrochet * 4 / 1000);
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, flValue1:Null<Float>, flValue2:Null<Float>, flValue3:Null<Float>, flValue4:Null<Float>, flValue5:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Hard Triggers':
				switch(value1)
				{
					case 'bring first':
						if (ClientPrefs.data.lowQuality) return;

						army3.forEach(function(spr:ZombieDancers)
						{
							FlxTween.tween(spr, {x: spr.x + 3000}, 2, {ease: FlxEase.sineOut});
						});

					case 'bring second':
						if (ClientPrefs.data.lowQuality) return;

						army2.forEach(function(spr:ZombieDancers)
						{
							FlxTween.tween(spr, {x: spr.x + 3000}, 2, {ease: FlxEase.sineOut});
						});

					case 'bring third':
						if (ClientPrefs.data.lowQuality) return;
						
						army1.forEach(function(spr:ZombieDancers)
						{
							FlxTween.tween(spr, {x: spr.x + 3000}, 2, {ease: FlxEase.sineOut});
						});

					case 'dark bg':
						FlxTween.tween(solidColBeh, {alpha: flValue2}, Conductor.stepCrochet * flValue3 / 1000, {ease: FlxEase.expoOut});

					case 'redVg':
						vignetter = !vignetter;

					case 'start':
						FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.linear});
				}
		}
	}
}