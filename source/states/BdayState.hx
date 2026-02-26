package states;

import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;

class BdayState extends MusicBeatState
{
	var bday:FlxSprite;
	override function create()
	{
		super.create();

		FlxG.sound.playMusic(Paths.music('so_retro'));

		bday = new FlxSprite().loadGraphic(Paths.image('bday_art'));
		bday.screenCenter();
		bday.scale.set(1.3, 1.3);
		add(bday);
	}

	override function update(elapsed:Float)
	{
		if(controls.BACK)
        {
			if (FlxG.save.data.finalSong)
				FlxG.sound.playMusic(Paths.music('final_mus'), 0.7);
			else
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
			
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

		if(controls.ACCEPT)
        {
			if (FlxG.save.data.finalSong)
				FlxG.sound.playMusic(Paths.music('final_mus'), 0.7);
			else
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
			
			FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

		super.update(elapsed);
	}
}
