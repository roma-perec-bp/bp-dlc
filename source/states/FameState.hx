package states;

import flixel.addons.text.FlxTypeText;

class FameState extends MusicBeatState
{
	var gyus:String =
		'DustGalaxy\n
		Glebiloid??? (idk if that counts)\n
		barsik barsika\n
		PeaTV (ahui)\n
		Tanooki228\n
		Badtime1207\n
		Francia_2020\n
		Geniy1234567\n
		Bobert_r';
	
	override function create()
	{
		var text:FlxText = new FlxText(0, 24, 0, "ARG Winners", 69);
		text.setFormat(Paths.font("mariones.ttf"), 69, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		add(text);

		var win:FlxText = new FlxText(150, 0, 0, gyus, 42);
		win.setFormat(Paths.font("mariones.ttf"), 42, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		win.screenCenter(Y);
		add(win);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if(controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

		super.update(elapsed);
	}
}