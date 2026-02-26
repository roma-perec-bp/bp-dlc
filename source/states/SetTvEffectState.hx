package states;

import backend.WeekData;
import backend.Highscore;

import flixel.FlxSubState;
import states.TitleState;

class SetTvEffectState extends MusicBeatState
{
	var alphabetArray:Array<Alphabet> = [];
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;

	// Week -1 = Freeplay
	public function new()
	{
		super();

		var text:Alphabet = new Alphabet(0, 160, "Enable TV Effect?", true);
		alphabetArray.push(text);
		text.scaleX = 0.7;
		text.scaleY = 0.7;
		text.screenCenter(X);
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
	}

	override function update(elapsed:Float)
	{
		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			onYes = !onYes;
			updateOptions();
		}
		if(controls.ACCEPT) {
			if(onYes) {
				ClientPrefs.data.tvEffect = true;
			}
			else{
				ClientPrefs.data.tvEffect = false;
			}
			ClientPrefs.saveSettings();

			if(FlxG.save.data.finalSong)
			{
				Init.fog = false;
				FlxG.sound.playMusic(Paths.music('final_mus'), 0.7);
				TitleState.gotFromTitle = false;
				FlxTransitionableState.skipNextTransOut = false;
				MusicBeatState.switchState(new MainMenuState());
			}
			else
				MusicBeatState.switchState(new TitleState());
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