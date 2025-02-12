package states;

import flixel.addons.text.FlxTypeText;
import objects.VideoSprite;

class CutState extends MusicBeatState
{
	var dialogueIntro:Array<String> = [
		'...',
		'Why?',
		'Why are you here again?',
		'I thought that we\'re done...',
		'I thought that was it... nothing more... no more new content...',
		'What are they doing again?',
		'...',
		'Look',
		'I have a feeling... bad feeling',
		'The next thing that you will experience... will be a horrible nightmare',
		'As i can see, this is the one shot of that one unbeatable song but remix',
		'You know... Sys guy or something',
		'But this one has pvz brutal ex crew or something',
		'Something that HE hates',
		'And it\'s...harder and cooler?',
		'About last thing i have a lots of doubts',
		'But still... Horrible as hell',
		'There is also more songs as i can see but i can\'t find it, maybe you can?',
		'...',
		'Okay i\'m wasting your time... sorry',
		'...',
		'It\'s time',
		'To end this',
		'For good',
		'See you soon'
	];

	var swagDialogue:FlxTypeText;
	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	public var videoCutscene:VideoSprite = null;
	
	override function create()
	{
		swagDialogue = new FlxTypeText(240, 520, Std.int(FlxG.width * 0.6), "", 18);
		swagDialogue.font = Paths.font("pixel-latin.ttf");
		swagDialogue.color = 0xFFFFFFFF;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.4)];
		add(swagDialogue);

		FlxG.sound.playMusic(Paths.music('0S0L'), 0.7);
		FlxG.sound.music.pitch = 0.5;

		new FlxTimer().start(1, function(timer:FlxTimer)
		{
			dialogueOpened = true;
			dialogueStarted = true;
			startDialogue(dialogueIntro);
		});

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			if(dialogueOpened)
			{
				if(dialogueEnded)
				{
					var dialogueList:Array<String>;
					dialogueList = dialogueIntro;
					if (dialogueList[1] == null && dialogueList[0] != null)
					{
						swagDialogue.alpha = 0;
						dialogueOpened = false;
						startVid();
						FlxG.sound.music.stop();
						FlxG.sound.music.pitch = 1;
					}
					else
					{
						dialogueList.remove(dialogueList[0]);
						startDialogue(dialogueList);
					}
				}
				else if (dialogueStarted)
				{
					swagDialogue.skip();
				}
			}
		}

		super.update(elapsed);
	}

	function startDialogue(dialogueList:Array<String>):Void
	{
		trace('startDialogue');
		swagDialogue.alpha = 1;
		swagDialogue.resetText(dialogueList[0]);

		swagDialogue.start(0.04, true);
		swagDialogue.completeCallback = function() {
			dialogueEnded = true;
		};
	
		dialogueEnded = false;
	}

	function startVid()
	{
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = Paths.video('intro');

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			videoCutscene = new VideoSprite(fileName, false, true, false);

			function onVideoEnd()
			{
				videoCutscene = null;
				MusicBeatState.switchState(new SetTvEffectState());
			}

			videoCutscene.finishCallback = onVideoEnd;
			videoCutscene.onSkip = onVideoEnd;

            add(videoCutscene);

            videoCutscene.play();
		}
		#else
		FlxG.log.warn('Platform not supported!');
		MusicBeatState.switchState(new SetTvEffectState());
		#end
	}

	override function destroy() 
	{
		#if VIDEOS_ALLOWED
		if(videoCutscene != null)
		{
			videoCutscene.destroy();
			videoCutscene = null;
		}
		#end

		super.destroy();
	}
}