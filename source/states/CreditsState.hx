package states;

import objects.AttachedSprite;
import openfl.filters.ShaderFilter;
import openfl.filters.BlurFilter;

import shaders.VCRMario85;
import shaders.ShadersHandler;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 0;

	private var grpOptions:FlxTypedGroup<FlxText>;
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var descBox:AttachedSprite;
	public var vcr:VCRMario85;
	var offsetThing:Float = -75;

	var debug:FlxText;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('bgFake'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFF313131;
		add(bg);
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		var defaultList:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			["Roma Perec",		"rom",		"Main Coder, composer, credits art, Peppers/Lawnmower/Box VA and 3D model creator", 't.me/romcock'],
			["PeaTV",		"pea",		"Zombies behind logo in title, It's a me cover icons and Zombie Pole Vaulter VA", 't.me/peatvofficial'],
			["Umbra",		"umbra",		"Main artist, Zombie Dancer VA", 't.me/umbrapvz'],
			["Foxxizm",		"fox",		"Song intro hands in NES style", 't.me/foxizzm'],
			["N",		"m",		"Banner art", 't.me/theeternalnight'],
			["Ender69",		"ender",		"Help with modchart", 't.me/ender69bunker'],
			["Hedgehog Gamer",		"hedgehog",		"Rokkie chromatic and pepper memes", 'https://youtube.com/@hui-s-kotletkami?si=esJGgE6oDDnYwj0o'],
			["SMixels2",		"smixels",		"BF icons lolz", 'https://youtube.com/@SMixels2']
		];
		
		for(i in defaultList)
			creditsStuff.push(i);
	
		var curID:Int = -1;
		for (i => credit in creditsStuff)
		{
			var optionText:FlxText = new FlxText(0, 0, 0, credit[0], 24);
			curID += 1;
			optionText.setFormat(Paths.font("mariones.ttf"), 24,  FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionText.borderSize = 4;
			optionText.ID = curID;
			grpOptions.add(optionText);
		}

		debug = new FlxText(5, 25, 0, "Press ENTER  to check socials", 55);
		debug.setFormat(Paths.font("vcr.ttf"), 15, 0xFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        debug.alpha = 0.7;
        debug.screenCenter(X);
		debug.borderSize = 1.5;
		add(debug);
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		changeSelection();
		super.create();

		vcr = new VCRMario85();

		if(ClientPrefs.data.tvEffect)
			FlxG.camera.setFilters([new ShaderFilter(vcr)]);
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}

			if(ClientPrefs.data.tvEffect)
				vcr.update(elapsed);
		}

		grpOptions.forEach(function(spr:FlxText)
        {
			var centX = (FlxG.height/2) - (spr.width /2);
            var centY = (FlxG.height/2) - (spr.height /2);

            spr.y = FlxMath.lerp(spr.y, centY - (curSelected-spr.ID) * 200, FlxMath.bound(elapsed * 10, 0, 1));

            var contrY = centX - Math.abs((curSelected-spr.ID))*200;
			var contrAngle = centY - Math.abs((curSelected-spr.ID))*20;

            spr.x = FlxMath.lerp(spr.x, contrY + 150, FlxMath.bound(elapsed * 10, 0, 1));

			spr.angle = (
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.angle, 0, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.angle, ((curSelected-spr.ID)) * -20, FlxMath.bound(elapsed * 10.2, 0, 1))
            );

            spr.scale.set(
                spr.ID == curSelected?
                    FlxMath.lerp(spr.scale.x, 1, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.8, FlxMath.bound(elapsed * 10.2, 0, 1)),
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 1, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.8, FlxMath.bound(elapsed * 10.2, 0, 1))
            );
            spr.alpha = (
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.alpha, 1, FlxMath.bound(elapsed * 5, 0, 1))
                    :
                    FlxMath.lerp(spr.alpha, 0.7, FlxMath.bound(elapsed * 5, 0, 1))
            );
        });
		
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected = FlxMath.wrap(curSelected + change, 0, creditsStuff.length - 1);

		descText.text = creditsStuff[curSelected][2];
		if(descText.text.trim().length > 0)
		{
			descText.visible = descBox.visible = true;
			descText.y = FlxG.height - descText.height + offsetThing - 60;
	
			if(moveTween != null) moveTween.cancel();
			moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});
	
			descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
			descBox.updateHitbox();
		}
		else descText.visible = descBox.visible = false;
	}
}
