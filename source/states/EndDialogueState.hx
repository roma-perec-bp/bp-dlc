package states;

import flixel.addons.text.FlxTypeText;
import objects.VideoSprite;

class EndDialogueState extends MusicBeatState
{
	var count:Int = 0;
	var dialogueIntro:Array<String> = [
		'...',
		'Well',
		'That was something',
		'Not gonna lie, i wasn\'t expecting more than one song',
		'That is truly... something...',
		'I guess you did find something interesting here',
		'As for me',
		'Well',
		'I found something but...',
		'I don\'t think it REALLY matters though',
		'I don\'t think it will try to do something with... someone...',
		'Anyways, there is nothing what i need so...',
		'I\'ll just go to something more interesting than that',
		'It was nice to meet you, even though you never saw me clearly',
		'Maybe i will see you again',
		'Who knows',
		'Who knows...',
		'The time is getting closer than you think...'
	];

	var swagDialogue:FlxTypeText;
	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	public var videoCutscene:VideoSprite = null;
	
	override function create()
	{
		Achievements.unlock('end');

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Won, actually won!", null);
		#end

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
						FlxG.save.data.finalSong = false;
						FlxG.save.data.ending = true;
						FlxG.save.flush();

						swagDialogue.alpha = 0;
						dialogueOpened = false;
						FlxG.sound.music.stop();
						FlxG.sound.music.pitch = 1;

						MusicBeatState.switchState(new SecondEndingState());
					}
					else
					{
						if(count == 16) //stop the music on final line
							FlxG.sound.music.stop();

						count++;

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
		swagDialogue.alpha = 1;
		swagDialogue.resetText(dialogueList[0]);

		swagDialogue.start(0.04, true);
		swagDialogue.completeCallback = function() {
			dialogueEnded = true;
		};
	
		dialogueEnded = false;
	}
}