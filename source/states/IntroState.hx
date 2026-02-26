package states;

class IntroState extends MusicBeatState
{
	override function create()
	{
		var bg = new FlxSprite().loadGraphic(Paths.image('bgDisc'));
		bg.color = FlxColor.GRAY;
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.alpha = 0.4;
		add(bg);
		bg.screenCenter();
	
		var love = new FlxSprite().loadGraphic(Paths.image('loveAndHateGrafix'));
		love.antialiasing = false;
		add(love);
		love.screenCenter();
		love.alpha = 0.0001;
	
		FlxTween.tween(love, {alpha: 1}, 1, {onComplete:
			function(twn:FlxTween) {
				FlxTween.tween(love, {alpha: 0}, 1, {startDelay: 1, onComplete:
					function(twn:FlxTween) {
						if(FlxG.save.data.firstTime == true)
							MusicBeatState.switchState(new FlashingState());
						else
						{
							MusicBeatState.switchState(new SetTvEffectState());
						}
					}
				});
			}
		});

		super.create();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("ENTERING", null);
		#end
	}
}