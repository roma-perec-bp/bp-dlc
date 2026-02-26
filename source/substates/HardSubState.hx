package substates;

import backend.WeekData;
import backend.Highscore;

import backend.StageData;
import backend.Song;

import flixel.FlxSubState;

class HardSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var onYes:Bool = true;
	var yesText:Alphabet;
	var noText:Alphabet;

	// Week -1 = Freeplay
	public function new()
	{
		super();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var text:Alphabet = new Alphabet(0, 180, 'Choose Difficulty', true);
		text.screenCenter(X);
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);

		yesText = new Alphabet(0, text.y + 150, Language.getPhrase('Normal'), true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);

		noText = new Alphabet(0, text.y + 150, Language.getPhrase('Hard'), true);
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);
		
		for(letter in noText.letters) letter.color = FlxColor.RED;
		updateOptions();
	}

	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.9) bg.alpha = 0.9;

		for (i in 0...alphabetArray.length) {
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			onYes = !onYes;
			updateOptions();
		}
		if(controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		} else if(controls.ACCEPT) {
			if(onYes) {
				PlayState.storyPlaylist = ['holy-hell'];
          		PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 1;
    
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
			else {
				PlayState.storyPlaylist = ['holy-hell'];
          		PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 2;
    
           		Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-hard', PlayState.storyPlaylist[0].toLowerCase());

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
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
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
}