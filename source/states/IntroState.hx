package states;
import objects.VideoSprite;

class IntroState extends MusicBeatState
{
	public var errorSine:Float = 0;
	public var errorText:FlxText;
	public var videoCutscene:VideoSprite = null;
	override function create()
	{
		if(FlxG.random.bool(1))
		{
			startVid();
		}
		else
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
		}

		super.create();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("ENTERING", null);
		#end
	}

	function startVid()
	{
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = Paths.video('2017');

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			var cutscene:VideoSprite = new VideoSprite(fileName, false, true, false, false);

			cutscene.finishCallback = function()
			{
				if(FlxG.save.data.firstTime == true)
					MusicBeatState.switchState(new FlashingState());
				else
				{
					MusicBeatState.switchState(new SetTvEffectState());
				}
			};

			// Skip callback
			cutscene.onSkip = function()
			{
                remove(cutscene);
				if(FlxG.save.data.firstTime == true)
					MusicBeatState.switchState(new FlashingState());
				else
				{
					MusicBeatState.switchState(new SetTvEffectState());
				}
			};

            add(cutscene);

            cutscene.play();
		}
		#else
		FlxG.log.warn('Platform not supported!');
		if(FlxG.save.data.firstTime == true)
			MusicBeatState.switchState(new FlashingState());
		else
		{
			MusicBeatState.switchState(new SetTvEffectState());
		}
		#end
	}
}