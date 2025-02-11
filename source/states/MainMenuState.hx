package states;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import backend.Song;

import openfl.filters.ShaderFilter;
import openfl.filters.BlurFilter;

import shaders.VCRMario85;
import shaders.ShadersHandler;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.2h'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxText>;

	var no:Bool = false;

	var optionShit:Array<String> = [
		'play',
		'gallery',
		'credits',
		'options'
	];

	public var vcr:VCRMario85;

	var selectorLeft:FlxText;
	var selectorRight:FlxText;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		Conductor.bpm = 146;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("MAIN MENU", null);
		#end

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		for (num => option in optionShit)
		{
			var item:FlxText = createMenuItem(option, 0, (num * 140) + 90);
			item.y += (4 - optionShit.length) * 70; // Offsets for when you have anything other than 4 items
			item.screenCenter(X);
		}

		selectorLeft = new FlxText(0, 0, 0, '>');
		selectorLeft.setFormat(Paths.font("mariones.ttf"), 48, FlxColor.WHITE);
		add(selectorLeft);
		selectorRight = new FlxText(0, 0, 0, '<');
		selectorRight.setFormat(Paths.font("mariones.ttf"), 48, FlxColor.WHITE);
		add(selectorRight);

		super.create();

		var psychVer:FlxText = new FlxText(12, FlxG.height - 64, 0, "Made in modified Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "BRUTAL PIZDEC Impotence DLC' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);

		psychVer.screenCenter(X);
		fnfVer.screenCenter(X);

		changeItem();

		FlxTransitionableState.skipNextTransOut = false;

		vcr = new VCRMario85();

		if(TitleState.gotFromTitle == true)
		{
			FlxG.camera.zoom += 1;
			FlxG.camera.shake(0.03, 0.5);
			TitleState.gotFromTitle = false;
			FlxG.camera.flash(FlxColor.RED, 2);
		}

		new FlxTimer().start(69, function(tmr:FlxTimer)
		{
			no = true;
			FlxTween.tween(FlxG.sound.music, {volume: 0.0}, 10);
			new FlxTimer().start(15, function(tmr:FlxTimer)
			{
				FlxG.sound.play(Paths.soundEmbed('arg'), 1, false, null, true, function() {
					new FlxTimer().start(5, function(tmr:FlxTimer)
					{
						no = false;
					});
				});
			});
		});

		if(ClientPrefs.data.tvEffect)
		{
			FlxG.camera.setFilters([ShadersHandler.chromaticAberration, ShadersHandler.radialBlur, new ShaderFilter(vcr)]);
			ShadersHandler.setChrome(0);
		}

		Init.fun = -1;
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxText
	{
		var menuItem:FlxText = new FlxText(x, y, 0);
		menuItem.text = name;
		menuItem.setFormat(Paths.font("mariones.ttf"), 48, FlxColor.WHITE, CENTER);
		menuItems.add(menuItem);
		return menuItem;
	}

	var selectedSomethin:Bool = false;
	override function update(elapsed:Float)
	{
		if(!no)
		{
			if (FlxG.sound.music.volume < 0.8)
				FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('buttonclick'));

				selectedSomethin = true;
				FlxG.mouse.visible = false;

				var item:FlxText;
				var option:String;

				option = optionShit[curSelected];
				item = menuItems.members[curSelected];

				switch (option)
				{
					case 'play':
						FlxTween.tween(FlxG.sound.music, {pitch: 0.01}, 1, {ease: FlxEase.quadOut});
						MusicBeatState.switchState(new StoryMenuState());

					case 'gallery':
						MusicBeatState.switchState(new GalleryState());
						Init.fog = false;

					case 'credits':
						MusicBeatState.switchState(new CreditsState());

					case 'ending debug':
						MusicBeatState.switchState(new EndState());
						Init.fog = false;

					case 'options':
						MusicBeatState.switchState(new OptionsState());
						OptionsState.onPlayState = false;
						if (PlayState.SONG != null)
						{
							PlayState.SONG.arrowSkin = null;
							PlayState.SONG.splashSkin = null;
							PlayState.stageUI = 'normal';
						}
				}
			}
		}

		super.update(elapsed);
		
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 0.95);

		if(ClientPrefs.data.tvEffect)
		{
			vcr.update(elapsed);
			ShadersHandler.setChrome(FlxG.random.int(2,6)/1000);
			ShadersHandler.setRadialBlur(640, 360,  FlxG.random.float(0.001, 0.01));
		}
	}

	override function beatHit()
	{
		if(Init.fog && ClientPrefs.data.camZooms) FlxG.camera.zoom += 0.03;
		super.beatHit();
	}

	function changeItem(change:Int = 0)
	{
		var prevEntry:Int = curSelected;

		curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);

		if (curSelected != prevEntry)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		var selectedItem:FlxText;
		selectedItem = menuItems.members[curSelected];

		selectorLeft.x = selectedItem.x - 63;
		selectorLeft.y = selectedItem.y;
		selectorRight.x = selectedItem.x + selectedItem.width + 15;
		selectorRight.y = selectedItem.y;
	}
}
