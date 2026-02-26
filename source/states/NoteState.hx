package states;

import flixel.addons.transition.FlxTransitionableState;
import backend.StageData;
import backend.Song;

class NoteState extends MusicBeatState
{
	var dark:FlxSprite;

	var press:Bool = true;

	override function create()
	{
		super.create();

		FlxG.save.data.gotNote = true;

		FlxG.sound.music.volume = 0;

		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image('hard_note'));
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

		FlxTween.tween(bg, {alpha: 1}, 1);
		FlxG.sound.play(Paths.sound('paper'));
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float)
	{
		if(press == true)
		{
			if (controls.ACCEPT)
			{
				press = false;

				PlayState.storyPlaylist = ['hard-mode'];
				PlayState.isStoryMode = true;

			 	FreeplayState.curSelected = 6;

				Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '', PlayState.storyPlaylist[0].toLowerCase());

			  	var directory = StageData.forceNextDirectory;
			  	LoadingState.loadNextDirectory();
			  	StageData.forceNextDirectory = directory;

			  	@:privateAccess
			  	if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			  	{
				  	trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
				  	Paths.freeGraphicsFromMemory();
			  	}

			  	LoadingState.prepareToSong();
			  	LoadingState.loadAndSwitchState(new PlayState());

			  	FlxG.sound.music.stop();
				return;
			}
		}

		super.update(elapsed);
	}
}
