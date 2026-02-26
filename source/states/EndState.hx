package states;

import flixel.addons.transition.FlxTransitionableState;
import backend.StageData;

class EndState extends MusicBeatState
{
	public static var end:Int;
	public static var gift:Bool = false;

	var dark:FlxSprite;

	var press:Bool = false;

	override function create()
	{
		super.create();

		FlxG.sound.music.volume = 0;

		var bg:FlxSprite = new FlxSprite();

		if(PlayState.usedBotplay == false)
		{
			if(FlxG.random.bool(6))
			{
				bg.loadGraphic(Paths.image('end', 'embed'));
				FlxG.sound.play(Paths.sound('comatose'));
			}
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
	
			ClientPrefs.saveSettings();
		}
		else
		{
			bg.loadGraphic(Paths.image('botEnd'));
			bg.screenCenter();
			bg.alpha = 1;
			add(bg);

			#if DISCORD_ALLOWED
			// Updating Discord Rich Presence
			DiscordClient.changePresence("Won... But in unfair way...", null);
			#end
	
			FlxG.sound.play(Paths.sound('botplay_ending'), 1, false, null, true, function() {
				PlayState.changedDifficulty = false;
				PlayState.usedBotplay = false;
				MusicBeatState.switchState(new PlayState());
			});
		}
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
					if(FlxG.random.bool(1))
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