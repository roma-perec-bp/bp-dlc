package states;

import flixel.addons.text.FlxTypeText;

import backend.StageData;
import backend.Song;

class FameState extends MusicBeatState
{
	var gyus:String =
		'DustGalaxy\n
		Glebiloid??? (idk if that counts)\n
		barsik barsika\n
		PeaTV (ahui)\n
		Tanooki228\n
		Badtime1207\n
		Francia_2020\n
		Geniy1234567\n
		Bobert_r';

	var dark:FlxSprite;
	var desc:FlxText;

	var pepChan:FlxSprite;
	var blackOVerlay:FlxSprite;

	var targetX:Float = FlxG.width;
	var targetY:Float = FlxG.height;
	var speed:Float = 1;

	static var escapedIntro:Bool = false;
	var quiting:Bool = false;
	
	override function create()
	{
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('uh oh'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var text:FlxText = new FlxText(0, -250, 0, "ARG Winners", 69);
		text.setFormat(Paths.font("mariones.ttf"), 69, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		add(text);
		FlxTween.tween(text, {y: 24}, 0.5, {ease: FlxEase.backOut});

		var win:FlxText = new FlxText(-450, 0, 0, gyus, 12);
		win.setFormat(Paths.font("mariones.ttf"), 12, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		win.screenCenter(Y);
		add(win);

		FlxTween.tween(win, {x: 150}, 1.5, {ease: FlxEase.quadOut});

		super.create();

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var leText:String = "Press ESCAPE to go back.";
		var size:Int = 12;
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("mariones.ttf"), size, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
		add(text);

		if (FlxG.save.data.beatUnfuck && !FlxG.save.data.unlockedSong.contains('caramelldansen'))
		{
			blackOVerlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackOVerlay.setGraphicSize(Std.int(blackOVerlay.width * 10));
			blackOVerlay.active = false;
			blackOVerlay.alpha = 0.0001;
			blackOVerlay.screenCenter();
			add(blackOVerlay);

			FlxG.mouse.visible = true;

			pepChan = new FlxSprite(FlxG.width, FlxG.height).loadGraphic(Paths.image('floatingPepChan'));
			pepChan.antialiasing = ClientPrefs.data.antialiasing;
			add(pepChan);
		}

		dark = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		dark.alpha = 0;
		dark.scrollFactor.set();
		add(dark);

		desc = new FlxText(0, -250, 0, "Привет\nэто список всех тех кто прошел арг по Брутал Пиздец ДЛС\nС помощью или без но эти герои справились\nСпасибо им за то что постарались пройти мое первое арг хехе\n(этот список обновлятся не будет)\n\n\nнажми ENTER чтоб продолжить", 42);
		desc.setFormat(Paths.font("HouseofTerrorRus.ttf"), 42, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		desc.screenCenter();
		desc.alpha = 0;
		add(desc);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("HALL OF FAME", null);
		#end

		if(!escapedIntro)
		{
			FlxTween.tween(dark, {alpha: 0.8}, 1);
			FlxTween.tween(desc, {alpha: 1}, 1);
		}
		else
			moveChan();
	}

	public var timerShit:FlxTimer;
	function moveChan()
	{
		targetX = FlxG.random.float(0, FlxG.width);
		targetY =  FlxG.random.float(0, FlxG.height);

		if(timerShit != null) timerShit.cancel();

		timerShit = new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			moveChan();
		});
	}

	override function update(elapsed:Float)
	{
		if(controls.BACK && quiting == false)
        {
			quiting = true;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

		if (FlxG.save.data.beatUnfuck && !FlxG.save.data.unlockedSong.contains('caramelldansen'))
		{
			if(quiting == false)
			{
				pepChan.x = FlxMath.lerp(pepChan.x, targetX, FlxMath.bound(elapsed * 60 * speed, 0, 0.1));
				pepChan.y = FlxMath.lerp(pepChan.y, targetY, FlxMath.bound(elapsed * 60 * speed, 0, 0.1));
	
				pepChan.angle -= speed;
	
				if (speed >= 1.1)
					speed -= 1;
	
				if(FlxG.mouse.overlaps(pepChan))
				{
					moveChan();
					speed = 30;
				}
			}

			if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(pepChan) && quiting == false)
			{
				quiting = true;
				FlxG.sound.music.stop();
				FlxG.sound.play(Paths.sound('winmusic'));
				FlxG.sound.play(Paths.sound('chime'));
				FlxTween.tween(pepChan.scale, {x: 4.4, y: 4.4}, 6, {ease: FlxEase.smootherStepInOut});
				pepChan.angle = 1;
				FlxTween.tween(pepChan, {x: (FlxG.width - pepChan.width) / 2, y: (FlxG.height - pepChan.height) / 2}, 6, {ease: FlxEase.smootherStepInOut});
				FlxTween.tween(blackOVerlay, {alpha: 1}, 6,
				{
					ease: FlxEase.linear,
					onComplete: function(twn:FlxTween)
					{
						PlayState.storyPlaylist = ['caramelldansen'];
						PlayState.isStoryMode = true;
		
						FreeplayState.curSelected = 5;
			
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

						return;
					}
				});
			}
		}

		if(controls.ACCEPT)
        {
			if (!escapedIntro && quiting == false)
			{
				escapedIntro = true;
				moveChan();
				FlxTween.cancelTweensOf(dark);
				FlxTween.cancelTweensOf(desc);
				FlxTween.tween(dark, {alpha: 0}, 1);
				FlxTween.tween(desc, {alpha: 0}, 1);
			}
        }

		super.update(elapsed);
	}
}