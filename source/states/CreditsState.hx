package states;

import objects.AttachedSprite;
import openfl.filters.ShaderFilter;
import openfl.filters.BlurFilter;

import backend.StageData;
import backend.Song;

import shaders.VCRMario85;
import shaders.ShadersHandler;

import states.FreeplayState;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 0;

	private var grpOptions:FlxTypedGroup<FlxText>;
	private var creditsStuff:Array<Array<String>> = [];

	var blackOVerlay:FlxSprite;

	var bg:FlxSprite;
	var descText:FlxText;
	var descBox:AttachedSprite;
	public var vcr:VCRMario85;
	var offsetThing:Float = -75;

	var textDep:FlxText;

	var debug:FlxText;

	var dust:FlxSprite;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('bgFake'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFF313131;
		add(bg);
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		var defaultList:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			["Roma Perec",		"rom",		"Director, Coder, Artist, Animator, Charter, 3D modelling and etc", 't.me/romcock'],
			["PeaTV",		"pea",		"Samples for Rockie Week and Zombie Pole Vaulter VA", 't.me/peatvofficial'],
			["Umbra",		"umbra",		"Artist, Zombie Dancer VA", 't.me/Umbramon'],
			["Toster",		"toster",		"Second Banner art and some arts for some songs", 't.me/ZG_YtugTefal'],
			["DustGalaxy",		"dustgalaxy",		"Artist and Composer", 'https://www.youtube.com/@DustGalaxy_Real'],
			["С1tr4m0n",		"citramon",		"Exerection Pepper freeplay art and icon", 't.me/c1tr4m0n'],
			["Poet_Digitalniy",		"fox",		"Song intro hands assets", null],
			["N",		"m",		"First Banner art", 't.me/theeternalnight'],
			["Ender69",		"ender",		"Help with modchart and other coding stuff", 't.me/ender69flock'],
			["Hedgehog Gamer",		"hedgehog",		"Rokkie chromatic, dust chromatic and pepper memes", 'https://t.me/hedgehoglmao228'],
			["SMixels2",		"smixels",		"BF icons", 'https://youtube.com/@SMixels2'],
			["Rozebud",		"rozebud",		"Pico icons i stole from fnf fps+ LMAO", 'https://x.com/helpme_thebigt']
		];
		
		for(i in defaultList)
			creditsStuff.push(i);
	
		var curID:Int = -1;
		for (i => credit in creditsStuff)
		{
			var optionText:FlxText = new FlxText(0, 0, 0, credit[0], 24);
			curID += 1;
			optionText.setFormat(Paths.font("mariones.ttf"), 24,  FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionText.borderSize = 4;
			optionText.ID = curID;
			grpOptions.add(optionText);
		}

		debug = new FlxText(5, 25, 0, "Press ENTER  to check socials", 55);
		debug.setFormat(Paths.font("vcr.ttf"), 15, 0xFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        debug.alpha = 0.7;
        debug.screenCenter(X);
		debug.borderSize = 1.5;
		add(debug);
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		dust = new FlxSprite(FlxG.width - 400, FlxG.height).loadGraphic(Paths.image('dust_easter'));
		dust.antialiasing = ClientPrefs.data.antialiasing;
		add(dust);

		blackOVerlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackOVerlay.setGraphicSize(Std.int(blackOVerlay.width * 10));
		blackOVerlay.active = false;
		blackOVerlay.alpha = 0.0001;
		blackOVerlay.screenCenter();
		add(blackOVerlay);

		textDep = new FlxText(50, 0, 1180, "Ну что?\nПоиграем?", 54);
		textDep.setFormat(Paths.font("tf2build.ttf"), 54, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		textDep.scrollFactor.set();
		textDep.screenCenter();
		textDep.active = false;
		textDep.alpha = 0.0001;
		add(textDep);

		changeSelection();
		super.create();

		vcr = new VCRMario85();

		if(ClientPrefs.data.tvEffect)
			FlxG.camera.setFilters([new ShaderFilter(vcr)]);
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.save.data.beatUnfuck && !FlxG.save.data.unlockedSong.contains('dep'))
		{
			if(curSelected == 4)
			{
				dust.y = FlxMath.lerp(dust.y, 300, FlxMath.bound(elapsed * 0.1, 0, 1));
				FlxG.mouse.visible = true;
			}
			else
			{
				dust.y = FlxMath.lerp(dust.y, FlxG.height, FlxMath.bound(elapsed * 10, 0, 1));
				FlxG.mouse.visible = false;
			}
		}

		if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(dust) && quitting == false)
		{
			quitting = true;

			FlxG.sound.music.fadeOut(2);
			FlxTween.tween(FlxG.sound.music, {pitch: 0}, 2);
			FlxTween.tween(blackOVerlay, {alpha: 1}, 2,
			{
				ease: FlxEase.linear,
				onComplete: function(twn:FlxTween)
				{
					FlxG.sound.play(Paths.sound('dust_unlock'));
					FlxG.sound.music.pitch = 1;
					textDep.alpha = 1;

					new FlxTimer().start(4, function(tmr:FlxTimer)
					{
						PlayState.storyPlaylist = ['dep'];
          				PlayState.isStoryMode = true;

						FreeplayState.curSelected = 4;
    
           				Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '', PlayState.storyPlaylist[0].toLowerCase());

            			var directory = StageData.forceNextDirectory;
						LoadingState.loadNextDirectory();
						StageData.forceNextDirectory = directory;

            			@:privateAccess
						if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
						{
							trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
							Paths.freeGraphicsFromMemory();
						}

						LoadingState.prepareToSong();
						LoadingState.loadAndSwitchState(new PlayState());
    
            			FlxG.sound.music.stop();
           				return;
					});
				}
			});
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}

			if(ClientPrefs.data.tvEffect)
				vcr.update(elapsed);
		}

		grpOptions.forEach(function(spr:FlxText)
        {
			var centX = (FlxG.height/2) - (spr.width /2);
            var centY = (FlxG.height/2) - (spr.height /2);

            spr.y = FlxMath.lerp(spr.y, centY - (curSelected-spr.ID) * 200, FlxMath.bound(elapsed * 10, 0, 1));

            var contrY = centX - Math.abs((curSelected-spr.ID))*200;
			var contrAngle = centY - Math.abs((curSelected-spr.ID))*20;

            spr.x = FlxMath.lerp(spr.x, contrY + 150, FlxMath.bound(elapsed * 10, 0, 1));

			spr.angle = (
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.angle, 0, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.angle, ((curSelected-spr.ID)) * -20, FlxMath.bound(elapsed * 10.2, 0, 1))
            );

            spr.scale.set(
                spr.ID == curSelected?
                    FlxMath.lerp(spr.scale.x, 1, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.8, FlxMath.bound(elapsed * 10.2, 0, 1)),
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 1, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.8, FlxMath.bound(elapsed * 10.2, 0, 1))
            );
            spr.alpha = (
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.alpha, 1, FlxMath.bound(elapsed * 5, 0, 1))
                    :
                    FlxMath.lerp(spr.alpha, 0.7, FlxMath.bound(elapsed * 5, 0, 1))
            );
        });
		
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected = FlxMath.wrap(curSelected + change, 0, creditsStuff.length - 1);

		descText.text = creditsStuff[curSelected][2];
		if(descText.text.trim().length > 0)
		{
			descText.visible = descBox.visible = true;
			descText.y = FlxG.height - descText.height + offsetThing - 60;
	
			if(moveTween != null) moveTween.cancel();
			moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});
	
			descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
			descBox.updateHitbox();
		}
		else descText.visible = descBox.visible = false;
	}
}
