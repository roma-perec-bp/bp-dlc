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

	var dark:FlxSprite;
	var desc:FlxText;
	
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

		dark = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		dark.alpha = 0;
		dark.scrollFactor.set();
		add(dark);

		desc = new FlxText(0, -250, 0, "Привет\nэто список всех тех кто прошел арг по Брутал Пиздец ДЛС\nС помощью или без но эти герои справились\nСпасибо им за то что постарались пройти мое первое арг хехе\n(этот список обновлятся не будет)\n\n\nнажми ENTER чтоб продолжить", 42);
		desc.setFormat(Paths.font("HouseofTerrorRus.ttf"), 42, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		desc.screenCenter();
		desc.alpha = 0;
		add(desc);

		super.create();

		FlxTween.tween(dark, {alpha: 0.8}, 1);
		FlxTween.tween(desc, {alpha: 1}, 1);
	}

	override function update(elapsed:Float)
	{
		if(controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }

		if(controls.ACCEPT)
        {
			FlxTween.cancelTweensOf(dark);
			FlxTween.cancelTweensOf(desc);
			FlxTween.tween(dark, {alpha: 0}, 1);
			FlxTween.tween(desc, {alpha: 0}, 1);
        }

		super.update(elapsed);
	}
}