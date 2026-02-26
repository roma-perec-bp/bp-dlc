package states;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import backend.StageData;
import backend.Song;

import flixel.input.keyboard.FlxKey;

import openfl.filters.ShaderFilter;
import openfl.filters.BlurFilter;

import shaders.VCRMario85;
import shaders.ShadersHandler;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxText>;

	var optionShit:Array<String> = [
		'start',
		'freeplay',
		'gallery',
		'credits',
		'hall of fame',
		'awards',
		'options'
	];

	var firstOptions:Array<String> = [
		'start',
		'credits',
		'options'
	];

	var finalOptions:Array<String> = [
		'final battle',
		'gallery',
		'credits',
		'hall of fame',
		'awards',
		'options'
	];

	var curOption:Array<String> = ['start'];

	public var vcr:VCRMario85;

	var selectorLeft:FlxText;
	var selectorRight:FlxText;

	var note:FlxSprite;

	var easterEggKeys:Array<String> = [
		'BEEDAY'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';

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

		if (FlxG.save.data.beatUnfuck == false)
			curOption = firstOptions;
		else if (FlxG.save.data.finalSong == true)
			curOption = finalOptions;
		else
			curOption = optionShit;

		for (num => option in curOption)
		{
			var item:FlxText = createMenuItem(option, 0, (num * 85) + 265);
			item.y += (4 - curOption.length) * 70; // Offsets for when you have anything other than 4 items
			item.screenCenter(X);
		}

		selectorLeft = new FlxText(0, 0, 0, '>');
		selectorLeft.setFormat(Paths.font("mariones.ttf"), 48, FlxColor.WHITE);
		add(selectorLeft);
		selectorRight = new FlxText(0, 0, 0, '<');
		selectorRight.setFormat(Paths.font("mariones.ttf"), 48, FlxColor.WHITE);
		add(selectorRight);

		if(FlxG.save.data.secretSongs == true && FlxG.save.data.finalSong == false && FlxG.save.data.ending == false && !FlxG.save.data.unlockedSong.contains('hard-mode'))
		{
			note = new FlxSprite(FlxG.width - 300, 300);
			note.frames = Paths.getSparrowAtlas('note_menu');
			note.animation.addByPrefix('idle', "idle", 24, true);
			note.animation.play('idle');
			note.antialiasing = ClientPrefs.data.antialiasing;
			add(note);

			FlxG.mouse.visible = true;
		}

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

		#if ACHIEVEMENTS_ALLOWED
		var leDate = Date.now();
		
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		FlxTransitionableState.skipNextTransOut = false;

		vcr = new VCRMario85();

		if(TitleState.gotFromTitle == true)
		{
			FlxG.camera.zoom += 1;
			FlxG.camera.shake(0.03, 0.5);
			TitleState.gotFromTitle = false;
			FlxG.camera.flash(FlxColor.RED, 2);
		}

		if(ClientPrefs.data.tvEffect)
		{
			FlxG.camera.setFilters([ShadersHandler.chromaticAberration, ShadersHandler.radialBlur, new ShaderFilter(vcr)]);
			ShadersHandler.setChrome(0);
		}
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxText
	{
		var menuItem:FlxText = new FlxText(x, y, 0);
		menuItem.text = name;
		menuItem.setFormat(Paths.font("mariones.ttf"), 42, FlxColor.WHITE, CENTER);
		menuItems.add(menuItem);
		return menuItem;
	}

	var selectedSomethin:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if(FlxG.save.data.secretSongs == true && !FlxG.save.data.unlockedSong.contains('hard-mode'))
		{
			if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(note) && selectedSomethin == false)
			{
				//FlxG.sound.music.fadeOut(1);
				MusicBeatState.switchState(new NoteState());
			}
		}

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

				option = curOption[curSelected];
				item = menuItems.members[curSelected];

				switch (option)
				{
					case 'start':
						FlxTween.tween(FlxG.sound.music, {pitch: 0.01}, 1, {ease: FlxEase.quadOut});
						MusicBeatState.switchState(new StoryMenuState());

					case 'final battle':
						PlayState.storyPlaylist = ['holy-hell'];
          				PlayState.isStoryMode = true;
    
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

					case 'awards':
						MusicBeatState.switchState(new AchievementsMenuState());

					case 'freeplay':
						MusicBeatState.switchState(new FreeplayState());

					case 'gallery':
						MusicBeatState.switchState(new GalleryState());
						Init.fog = false;

					case 'hall of fame':
						MusicBeatState.switchState(new FameState());

					case 'credits':
						MusicBeatState.switchState(new CreditsState());

					case 'ending debug':
						MusicBeatState.switchState(new EndState());
						Init.fog = false;

					case 'second ending debug':
						MusicBeatState.switchState(new EndDialogueState());
						Init.fog = false;

					case 'devil sequence':
						MusicBeatState.switchState(new DevilState());
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

			if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if(allowedKeys.contains(keyName)) {
					easterEggKeysBuffer += keyName;
					if(easterEggKeysBuffer.length >= 32) easterEggKeysBuffer = easterEggKeysBuffer.substring(1);
					//trace('Test! Allowed Key pressed!!! Buffer: ' + easterEggKeysBuffer);

					for (wordRaw in easterEggKeys)
					{
						var word:String = wordRaw.toUpperCase(); //just for being sure you're doing it right
						if (easterEggKeysBuffer.contains(word))
						{
							//trace('YOOO! ' + word);
							if (FlxG.save.data.psychDevsEasterEgg == word)
								FlxG.save.data.psychDevsEasterEgg = '';
							else
								FlxG.save.data.psychDevsEasterEgg = word;
							FlxG.save.flush();

							FlxG.sound.play(Paths.sound('secret'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
								function(twn:FlxTween) {
									MusicBeatState.switchState(new BdayState());
									Init.fog = false;
								}
							});
							selectedSomethin = true;
							FlxG.sound.music.fadeOut();
							if(FreeplayState.vocals != null)
							{
								FreeplayState.vocals.fadeOut();
							}
							easterEggKeysBuffer = '';
							break;
						}
					}
				}
			}
		}

		super.update(elapsed);
		
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 0.95);

		if(ClientPrefs.data.tvEffect)
		{
			vcr.update(elapsed);
			ShadersHandler.setChrome(FlxG.random.int(1,3)/1000);
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

		curSelected = FlxMath.wrap(curSelected + change, 0, curOption.length - 1);

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
