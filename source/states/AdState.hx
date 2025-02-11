package states;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import backend.StageData;
import objects.VideoSprite;

class AdState extends MusicBeatState
{
    public var videoCutscene:VideoSprite = null;

	var videoShow:String = 'brutal-pizdec';
	var link:String = 'https://discord.gg/9crVmT7dfA';
	var imageThing:String = 'bgDesat';

	var canChoose:Bool = true;

	var alphabetArray:Array<Alphabet> = [];
	var onYes:Bool = false;

	var text:Alphabet;
	var yesText:Alphabet;
	var noText:Alphabet;

	var debug:FlxText;
	var ban:FlxSprite;

	var ad:Int = 0;

	var adEnd:Bool = false;

    override function create()
	{
		text = new Alphabet(0, 160, 'Wanna watch an AD\nto respawn in previous wave?', true);
		text.screenCenter(X);
		alphabetArray.push(text);
		text.alpha = 1;
		add(text);

		yesText = new Alphabet(0, text.y + 250, 'Yes', true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);
		noText = new Alphabet(0, text.y + 250, 'No', true);
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);
		
		updateOptions();

		super.create();

		ad = FlxG.random.int(0,9);

		switch(ad)
		{
			case 0:
				videoShow = 'ads/0';
				link = 'https://discord.gg/9crVmT7dfA';
				imageThing = 'ads/0';
			case 1:
				videoShow = 'ads/1';
				link = 'https://www.youtube.com/@RomPepperBP';
				imageThing = 'ads/1';
			case 2:
				videoShow = 'ads/2';
				link = null;
				imageThing = null;
			case 3:
				videoShow = 'ads/3';
				link = 'https://www.youtube.com/@RomMusicBP';
				imageThing = 'ads/3';
			case 4:
				videoShow = 'ads/4';
				link = null;
				imageThing = null;
			case 5:
				videoShow = 'ads/5';
				link = 'https://gamebanana.com/mods/533983';
				imageThing = 'ads/5';
			case 6:
				videoShow = 'ads/6';
				link = null;
				imageThing = null;
			case 7:
				videoShow = 'ads/7';
				link = 't.me/romcock';
				imageThing = 'ads/7';
			case 8:
				videoShow = 'ads/8';
				link = 'https://rom4chek.itch.io/protect-me';
				imageThing = 'ads/8';
			case 9:
				videoShow = 'ads/9';
				link = 't.me/umbrapvz';
				imageThing = 'ads/9';
		}

		ban = new FlxSprite(0, 0).loadGraphic(Paths.image(imageThing));
		ban.antialiasing = ClientPrefs.data.antialiasing;
		ban.updateHitbox();
		ban.screenCenter();
		ban.setGraphicSize(FlxG.width, FlxG.height);
		ban.alpha = 0;
		add(ban);

		debug = new FlxText(5, FlxG.height-135, 0, "Press ENTER to check the thing || Press ESCAPE to play the song", 55);
		debug.setFormat(Paths.font("HouseofTerror.ttf"), 55, 0xFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debug.alpha = 0;
		debug.screenCenter(X);
		debug.borderSize = 4;
		add(debug);
    }
	
	override function update(elapsed:Float)
	{
		if(canChoose)
		{
			if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				FlxG.sound.play(Paths.sound('scrollMenu'), 1);
				onYes = !onYes;
				updateOptions();
			}

			if(controls.ACCEPT) {
				if(onYes)
				{
					PlayState.respawned = true;
	
					switch(PlayState.respawnPoint)
					{
						case 1:
							PlayState.startOnTime = 176934.231412759;
						case 2:
							PlayState.startOnTime = 341409.755888285;
						case 3:
							PlayState.startOnTime = 499908.189969542;
					}
	
					canChoose = false;
					text.alpha = 0;
					yesText.alpha = 0;
					noText.alpha = 0;
					adStart();
				}
				else
				{
					PlayState.respawnPoint = 0;

					MusicBeatState.switchState(new PlayState());
				}
			}
		}

		if(adEnd)
		{
			if(controls.ACCEPT)
			{
				CoolUtil.browserLoad(link);
			}
			else if(controls.BACK)
			{
				MusicBeatState.switchState(new PlayState());
			}
		}
		super.update(elapsed);
	}

	function updateOptions() {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
	}

	public function endAd()
	{
		if(link != null && imageThing != null)
		{
			FlxTween.tween(ban, {alpha: 1}, 1);
			FlxTween.tween(debug, {alpha: 1}, 1);

			adEnd = true;
		}
		else
		{
			MusicBeatState.switchState(new PlayState());
		}
	}

	public function adStart()
	{
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = Paths.video(videoShow);

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			var cutscene:VideoSprite = new VideoSprite(fileName, false, false, false, false);

			function onVideoEnd()
			{
				cutscene = null;
				endAd();
			}

			cutscene.finishCallback = onVideoEnd;

            add(cutscene);

            cutscene.play();
		}
		#else
		FlxG.log.warn('Platform not supported!');
		endAd();
		#end
	}
}