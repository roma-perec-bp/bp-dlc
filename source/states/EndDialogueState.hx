package states;

import flixel.addons.text.FlxTypeText;
import objects.VideoSprite;

class EndDialogueState extends MusicBeatState
{
	var dialogueIntro:Array<String> = [
		'...',
		'Well',
		'That was something',
		'I guess you did find something interesting here',
		'As for me',
		'Well',
		'There is nothing what i need so...',
		'I\'ll just go to something more interesting than that',
		'It was nice to meet you, even though you never saw me clearly',
		'Maybe i will see you again',
		'Who knows',
		'Who knows...',
		'The time is getting closer than you think...',
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
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		FlxG.sound.playMusic(Paths.music('0S0L'), 0.7);
		FlxG.sound.music.pitch = 0.25;

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
						FlxG.sound.music.stop();
						FlxG.sound.music.pitch = 1;

						FlxG.sound.play(Paths.soundEmbed('transmission'), 0.6, false, null, true, function() {
							MusicBeatState.switchState(new EndingState());
						});
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
}