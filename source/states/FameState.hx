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
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('uh oh'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var text:FlxText = new FlxText(0, -250, 0, "ARG Winners", 69);
		text.setFormat(Paths.font("mariones.ttf"), 69, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		add(text);
		FlxTween.tween(text, {y: 24}, 0.5, {ease: FlxEase.backOut});

		var win:FlxText = new FlxText(-450, 0, 0, gyus, 12);
		win.setFormat(Paths.font("mariones.ttf"), 12, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		win.screenCenter(Y);
		add(win);

		FlxTween.tween(win, {x: 150}, 1.5, {ease: FlxEase.quadOut});

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