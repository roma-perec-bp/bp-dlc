package states;

import flixel.addons.transition.FlxTransitionableState;
import backend.StageData;

class EndState extends MusicBeatState
{
	public static var end:Int;
	public static var gift:Bool = false;

	var dark:FlxSprite;

	var press:Bool = false;

	var randomLike:Array<String> =
	[
		'https://www.youtube.com/watch?v=3tlo6PQKefk',
		'https://www.youtube.com/watch?v=1Qm7QmLVrc4',
		'https://www.youtube.com/watch?v=kq4oUKQBRys',
		'https://www.youtube.com/watch?v=1Wytn-_MSBo',
		'https://www.youtube.com/watch?v=VUuM6Iw14II',
		'https://www.youtube.com/watch?v=9iCN34CDHV4',
		'https://www.youtube.com/watch?v=Dmvsy2xnon8',
		'https://www.youtube.com/watch?v=fwdV2vWNvZw',
		'https://www.youtube.com/watch?v=SyI3kJoKRk4',
		'https://www.youtube.com/watch?v=Ie-I24W5DNs',
		'https://www.youtube.com/watch?v=l7GObEWKTwA'
	];

	override function create()
	{
		super.create();

		FlxG.sound.music.volume = 0;

		var bg:FlxSprite = new FlxSprite();

		if(PlayState.changedDifficulty == false)
		{
			if(Init.fun >= 67 && Init.fun <= 68)
				bg.loadGraphic(Paths.image('end', 'embed'));
			else
				bg.loadGraphic(Paths.image('end'));
			bg.screenCenter();
			bg.alpha = 0;
			add(bg);
	
			var te:FlxText = new FlxText(0, FlxG.height-135, 1200, 'Press ACCEPT to continue', 32);
			te.setFormat(Paths.font("HouseofTerror.ttf"), 32, 0xFFd4a967, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			te.screenCenter(X);
			add(te);
	
			dark = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			dark.alpha = 0;
			add(dark);
			
			FlxTween.tween(bg, {alpha: 1}, 1, {onComplete:
				function (twn:FlxTween)
				{
					press = true;
				}
			});
	
			FlxG.sound.play(Paths.sound('paper'));
			
			#if DISCORD_ALLOWED
			// Updating Discord Rich Presence
			DiscordClient.changePresence("Won... But at what cost?", null);
			#end

			if(Init.fun >= 67 && Init.fun <= 68) FlxG.sound.play(Paths.sound('comatose'));
	
			ClientPrefs.saveSettings();
		}
		else
		{
			if(Init.fun == 100)
			{
				Sys.command('mshta vbscript:Execute("msgbox ""LMAO YOU DID IT WITH BOTPLAY??? XDDDDDDDDDD YOU SUCK LMAO GO FUCK YOURSELF BETA CUCK"":close")');
				CoolUtil.browserLoad(randomLike[FlxG.random.int(0, 10)]);
				Sys.exit(1);
			}
			else
			{
				bg.loadGraphic(Paths.image('botEnd'));
				bg.screenCenter();
				bg.alpha = 1;
				add(bg);
	
				FlxG.sound.play(Paths.sound('botplay_ending'), 1, false, null, true, function() {
					PlayState.changedDifficulty = false;
					MusicBeatState.switchState(new PlayState());
				});
			}
		}

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Won... But in unfair way...", null);
		#end
	}

	override function update(elapsed:Float)
	{
		if(press == true)
		{
			if (controls.ACCEPT)
			{
				ClientPrefs.saveSettings();
				FlxG.camera.fade(FlxColor.BLACK, 3);
				new FlxTimer().start(5, function(tmr:FlxTimer)
				{
					if(Init.fun == 66)
					{
						FlxTransitionableState.skipNextTransIn = true;
						MusicBeatState.switchState(new SmileState());
					}
					else
						MusicBeatState.switchState(new EndingState());
				});
			}
		}

		super.update(elapsed);
	}
}