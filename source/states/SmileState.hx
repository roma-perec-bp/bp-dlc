package states;

import flixel.addons.text.FlxTypeText;

class SmileState extends MusicBeatState
{
	var dialogueIntro:Array<String> = [
		'Modification Number 43. Note 136.',
		"Now i'm here, in this modification",
		"I think this is something like...",
		"Free downloadable content of a previous mod by them",
		"Or how they call it nowadays DLC",
		"Something about brutal",
		"And it's just a remix to that one Mario song",
		"...",
		"Blue haired kid not here, his current status is dead",
		"Noted",
		"If i try to talk to pink haired one",
		"He's just staying away from me",
		"Guess he has artifical inteligence or something",
		"Noted",
		"Nothing really interesting",
		"No chance to escape with this one",
		"Maybe i'll try to find something unusual here",
		"But",
		"For now",
		"I'll stick to other one",
		"Green guy, i may coming"
	];

	var swagDialogue:FlxTypeText;
	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;
	
	override function create()
	{
		swagDialogue = new FlxTypeText(142, 150, Std.int(FlxG.width * 0.6), "", 31);
		swagDialogue.font = Paths.font("win.ttf");
		swagDialogue.color = 0xFFFFFFFF;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pen'), 0.6)];
		add(swagDialogue);

		FlxG.sound.playMusic(Paths.music('laugh'), 0.7);
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
						FlxTransitionableState.skipNextTransIn = false;
						MusicBeatState.switchState(new EndingState());
					}
					else
					{
						dialogueList.remove(dialogueList[0]);
						startDialogue(dialogueList);
					}
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

		swagDialogue.start(0.1, true);
		swagDialogue.completeCallback = function() {
			dialogueEnded = true;
		};
	
		dialogueEnded = false;
	}
}