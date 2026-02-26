package states;

import flixel.addons.text.FlxTypeText;
import objects.Character;
import psychlua.LuaUtils;

class DevilState extends MusicBeatState
{
	var devil:Character = null;

	public var crashSaver:FlxSound;

	var curDil:Int = 0;
	var dialogueIntro:Array<String> = [
		'*смех*',
		'Привет!',
		'Я вижу тебе понравился концерт 10 минутный, не так ли?',
		'Мои поданные хорошо справились со своей работой.',
		'*Вздох* Я думаю этот челик уже и так настрадался, наверное отпущу...',
		'А может и нет! *Смех*',
		'В любом случае хватит про него, давай поговорим о тебе, голубоволосый!',
		'Я вижу ты перессекался с моими существами из ада.',
		'Монохромный, тот пиксельно красный и другие...',
		'Я вижу в тебе потенциал маленького надоедливого рэпующего дьяволёнка, который будет бесить всех и справляться с работой намного лучше чем остальные!',
		'Но всего этого что ты имеешь на данный момент, недостаточно!',
		'Докажи, что ты достоин быть настоящим чертом!',
		'Найди мои 6 песен и пройди их!',
		'И тогда у тебя будет шанс стать одним из нас!',
		'Только не думай что ты сразу будешь чертом, когда всё это сделаешь.',
		'Ты ведь в будущем можешь им даже и не стать, даже несмотря на то что ты все это сделаешь!',
		'Это уже не от меня зависит, а от мира нашего!',
		'Ладно, желаю удачи...',
		'Не проебись...'
	];

	public var devilTalk:FlxSound;

	var swagDialogue:FlxTypeText;
	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;
	
	override function create()
	{
		devil = new Character(216, 50, 'pep-devil-dark', false);
		devil.updateHitbox();
		devil.dance();
		devil.alpha = 0.0001;
		add(devil);

		swagDialogue = new FlxTypeText(0, 520, Std.int(FlxG.width * 0.6), "", 42);
		swagDialogue.font = Paths.font("HouseofTerrorRus.ttf");
		swagDialogue.alignment = CENTER;
		swagDialogue.color = 0xFFFF0000;
		swagDialogue.screenCenter(X);
		//swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.4)];
		add(swagDialogue);

		crashSaver = new FlxSound().loadEmbedded(Paths.sound('devil_appear'));
		FlxG.sound.list.add(crashSaver);
		crashSaver.play();
		//FlxG.sound.play(Paths.sound('devil_appear'));

		FlxG.sound.playMusic(Paths.music('devil_song'), 0.6);
		FlxG.sound.music.pitch = 0.6;

		new FlxTimer().start(3, function(timer:FlxTimer)
		{
			devil.playAnim('intro', true);
			devil.specialAnim = true;
			devil.alpha = 1;
			dialogueOpened = true;
			dialogueStarted = true;

			FlxG.camera.shake(0.066, 0.2);
			FlxG.camera.flash(0xFFFF0000, 1, null, true);

			startDialogue(dialogueIntro);
		});

		super.create();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Talking with the devil...", null);
		#end
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
						FlxG.save.data.talkDevil = true;
						FlxG.save.flush();

						FlxG.camera.fade(FlxColor.BLACK, 1, false);
						dialogueOpened = false;
						FlxG.sound.music.fadeOut(1);
						
						new FlxTimer().start(3, function(timer:FlxTimer)
						{
							var tag:String = LuaUtils.formatVariable('voices_devil');
							var variables = MusicBeatState.getVariables();
							var snd:FlxSound = variables.get(tag);
							if(snd != null)
							{
								snd.stop();
								variables.remove(tag);
							}

							FlxG.sound.music.stop();
							FlxG.sound.music.pitch = 1;

							new FlxTimer().start(0.01, function(timer:FlxTimer)
							{
								FlxG.sound.playMusic(Paths.music('freakyMenu'));
								MusicBeatState.switchState(new FreeplayState());
							});
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
		/*var variables = MusicBeatState.getVariables();
		var snd:FlxSound = variables.get(LuaUtils.formatVariable('voices'));
		if(snd != null)
		{
			snd.stop();
			variables.remove(LuaUtils.formatVariable('voices'););
		}*/

		if (curDil != 19)
		{
			var variables = MusicBeatState.getVariables();
			var tag:String = LuaUtils.formatVariable('voices_devil');
			var oldSnd = variables.get(tag);
			if(oldSnd != null)
			{
				oldSnd.stop();
				oldSnd.destroy();
			}
	
			variables.set(tag, FlxG.sound.play(Paths.sound('devil_quest/start/'+curDil), 1, false, null, true, function()
			{
				variables.remove(tag);
			}));
	
			curDil++;
		}

		swagDialogue.alpha = 1;
		swagDialogue.resetText(dialogueList[0]);

		swagDialogue.start(0.06, true);
		swagDialogue.completeCallback = function() {
			dialogueEnded = true;
		};
	
		dialogueEnded = false;
	}
}