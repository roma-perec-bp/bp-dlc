package states.stages;

import states.stages.objects.*;
import objects.Character;

class StageCaramel extends BaseStage
{
	var bg:FlxSprite;
	var blackOVerlay:FlxSprite;
	var flashu:FlxSprite;
	var curBG:Int = -1;

	var suffixDance:String = '-caramel';
	var canBop:Bool = false;

	var pepchan:FlxSprite;

	var pepWheelLeft:FlxSprite;
	var pepWheelRight:FlxSprite;

	var rom:FlxSprite;

	var jumpersGrp:FlxTypedGroup<FlxSprite>;
	override function create()
	{
		curBG = FlxG.random.int(0, 13, [curBG]);
		bg = new FlxSprite(0,0).loadGraphic(Paths.image('bgs/'+ curBG));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(FlxG.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.cameras = [camHudBehind];
		add(bg);

		blackOVerlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackOVerlay.setGraphicSize(Std.int(blackOVerlay.width * 10));
		blackOVerlay.active = false;
		blackOVerlay.alpha = 1;
		bg.screenCenter();
		blackOVerlay.cameras = [camHudBehind];
		add(blackOVerlay);

		flashu = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		flashu.setGraphicSize(Std.int(flashu.width * 10));
		flashu.active = false;
		flashu.alpha = 0.00001;
		flashu.screenCenter();
		flashu.blend = ADD;
		flashu.cameras = [camHudBehind];
		add(flashu);

		if (!ClientPrefs.data.lowQuality)
		{
			jumpersGrp = new FlxTypedGroup<FlxSprite>();
			add(jumpersGrp);
		}

		pepchan = new FlxSprite(0,0);
		pepchan.frames = Paths.getSparrowAtlas('characters/pep_chan');
		pepchan.animation.addByIndices('danceLeft-caramel', 'dance', [0,1,2,3,4,5,6,7,8,9], "", 24, false);
		pepchan.animation.addByIndices('danceRight-caramel', 'dance', [10,11,12,13,14,15,16,17,18], "", 24, false);
		pepchan.animation.addByIndices('danceLeft-default', 'idle', [0,1,2,3,4,5,6,7,8], "", 24, false);
		pepchan.animation.addByIndices('danceRight-default', 'idle', [10,11,12,13,14,15,16,17], "", 24, false);
		pepchan.animation.play('danceLeft'+suffixDance, true);
		pepchan.antialiasing = ClientPrefs.data.antialiasing;
		pepchan.updateHitbox();
		pepchan.screenCenter();
		pepchan.color = 0xFF000000;
		pepchan.y += 1250;
		pepchan.cameras = [camHudBehind];
		pepchan.scale.set(1.35, 1.35);
		add(pepchan);

		pepWheelLeft = new FlxSprite(-200,0);
		pepWheelLeft.frames = Paths.getSparrowAtlas('characters/wheeller');
		pepWheelLeft.animation.addByIndices('danceLeft', 'singer', [0,1,2,3,4,5,6,7,8,9], "", 24, false);
		pepWheelLeft.animation.addByIndices('danceRight', 'singer', [10,11,12,13,14,15,16], "", 24, false);
		pepWheelLeft.animation.play('danceLeft', true);
		pepWheelLeft.antialiasing = ClientPrefs.data.antialiasing;
		pepWheelLeft.cameras = [camHudBehind];
		pepWheelLeft.scale.set(1.5,1.5);
		add(pepWheelLeft);

		pepWheelRight = new FlxSprite(1280,0);
		pepWheelRight.frames = Paths.getSparrowAtlas('characters/wheeller');
		pepWheelRight.animation.addByIndices('danceLeft', 'singer', [0,1,2,3,4,5,6,7,8,9], "", 24, false);
		pepWheelRight.animation.addByIndices('danceRight', 'singer', [10,11,12,13,14,15,16], "", 24, false);
		pepWheelRight.animation.play('danceLeft', true);
		pepWheelRight.antialiasing = ClientPrefs.data.antialiasing;
		pepWheelRight.cameras = [camHudBehind];
		pepWheelRight.scale.set(1.5,1.5);
		pepWheelRight.flipX = true;
		add(pepWheelRight);

		pepWheelLeft.screenCenter(Y);
		pepWheelRight.screenCenter(Y);

		rom = new FlxSprite(0,1500);
		rom.frames = Paths.getSparrowAtlas('characters/romers');
		rom.animation.addByPrefix('idle', 'rom_thinker', 24, true);
		rom.animation.addByPrefix('idea', 'rom_yesser', 24, false);
		rom.animation.play('idle', true);
		rom.antialiasing = ClientPrefs.data.antialiasing;
		rom.cameras = [camHudBehind];
		rom.scale.set(1.5,1.5);
		rom.screenCenter(X);
		add(rom);

		new FlxTimer().start(FlxG.random.int(10, 20), function(tmr:FlxTimer)
		{
			changeBg();
		});
	}

	function changeBg()
	{
		var fadeBG:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image('bgs/'+ curBG));
		fadeBG.antialiasing = ClientPrefs.data.antialiasing;
		fadeBG.setGraphicSize(Std.int(FlxG.width * 1.1));
		fadeBG.updateHitbox();
		fadeBG.screenCenter();
		fadeBG.cameras = [camHudBehind];
		insert(members.indexOf(blackOVerlay), fadeBG);
		add(fadeBG);

		FlxTween.tween(fadeBG, {alpha: 0}, 2,
		{
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				fadeBG.destroy();
				fadeBG.kill();
				remove(fadeBG, true);
			}
		});

		curBG = FlxG.random.int(0, 13, [curBG]);
		bg.loadGraphic(Paths.image('bgs/'+ curBG));
		bg.setGraphicSize(Std.int(FlxG.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();

		new FlxTimer().start(FlxG.random.int(10, 20), function(tmr:FlxTimer)
		{
			changeBg();
		});
	}

	function jumpers()
	{
		if (ClientPrefs.data.lowQuality) return;
		
		var jumper:FlxSprite = new FlxSprite(FlxG.random.int(200, 1000), FlxG.height).loadGraphic(Paths.image('characters/jumper'));
		jumper.antialiasing = ClientPrefs.data.antialiasing;
		jumper.cameras = [camHudBehind];
		jumpersGrp.add(jumper);

		FlxTween.tween(jumper, {y: jumper.y - 250}, 0.5, {
			ease: FlxEase.expoOut,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(jumper, {y: jumper.y + 500}, 0.5, {
					ease: FlxEase.expoIn,
				});
			}
		});

		FlxTween.tween(jumper, {angle: FlxG.random.int(90, -90)}, 1,
		{
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				jumper.destroy();
				jumper.kill();
				jumpersGrp.remove(jumper, true);
			}
		});
	}

	var danceLeft:Bool = false;
	override function beatHit()
	{
		if(canBop)
		{
			FlxTween.cancelTweensOf(pepchan);
			//pepchan.screenCenter(Y);
			pepchan.y = 250;
			FlxTween.tween(pepchan, {y: pepchan.y - 25}, 0.30, {ease: FlxEase.circOut});
		}

		danceLeft = !danceLeft;

		if (danceLeft)
		{
			pepchan.animation.play('danceRight'+suffixDance);
			pepWheelLeft.animation.play('danceRight');
			pepWheelRight.animation.play('danceRight');
		}
		else
		{
			pepchan.animation.play('danceLeft'+suffixDance);
			pepWheelLeft.animation.play('danceLeft');
			pepWheelRight.animation.play('danceLeft');
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, flValue1:Null<Float>, flValue2:Null<Float>, flValue3:Null<Float>, flValue4:Null<Float>, flValue5:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Caramel Triggers":
				switch(value1)
				{
					case 'black off':
						camHudBehind.flash(0xFFFFFFFF, 0.3, null, true);
						blackOVerlay.alpha = 0.6;

					case 'black end':
						camHudBehind.flash(0xFFFFFFFF, 1, null, true);
						blackOVerlay.alpha = 1;
						pepWheelRight.visible = false;
						pepWheelLeft.visible = false;
						pepchan.visible = false;

						if (ClientPrefs.data.lowQuality) return;

						jumpersGrp.forEach(function(spr:FlxSprite)
						{
							spr.visible = false;
						});

					case 'jumper':
						jumpers();

					case 'pep appear':
						FlxTween.tween(pepchan, {y: 250}, 0.5, {ease: FlxEase.expoOut});

					case 'pep bye':
						canBop = false;
						FlxTween.tween(pepchan, {y: 1250}, 0.5, {ease: FlxEase.expoIn});

					case 'pep white':
						pepchan.color = 0xFFFFFFFF;
					case 'pep black':
						pepchan.color = 0xFF000000;

					case 'caramel suffix':
						suffixDance = '-caramel';
						pepchan.offset.set(0, 0);

					case 'default suffix':
						suffixDance = '-default';
						pepchan.offset.set(-35, 0);

					case 'flashes':
						if (!ClientPrefs.data.flashing) return;

						flashu.alpha = 0.1;
						FlxTween.tween(flashu, {alpha: 0.00001}, 0.3);

					case 'can bop':
						canBop = !canBop;

					case 'left singer sing':
						FlxTween.tween(pepWheelLeft, {x: 150}, 1, {ease: FlxEase.quadOut});

					case 'left singer out':
						FlxTween.tween(pepWheelLeft, {x: -200}, 1, {ease: FlxEase.quadIn});

					case 'right singer sing':
						FlxTween.tween(pepWheelRight, {x: 850}, 1, {ease: FlxEase.quadOut});

					case 'right singer out':
						FlxTween.tween(pepWheelRight, {x: 1280}, 1, {ease: FlxEase.quadIn});

					case 'rom appear':
						FlxTween.tween(rom, {y: 350}, 2, {ease: FlxEase.sineOut});

					case 'rom bye':
						rom.animation.play('idea', true);
						rom.x = rom.x - 5;

						new FlxTimer().start(0.6, function(tmr:FlxTimer)
						{
							FlxTween.tween(rom, {y: 2000}, 0.6, {ease: FlxEase.expoIn});
						});
				}
		}
	}
}