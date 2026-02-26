package states;

import states.editors.ChartingState;
import backend.WeekData;
import objects.HealthIcon;
import backend.Highscore;
import backend.Song;
import substates.ResetScoreSubState;
import substates.HardSubState;
import backend.Mods;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import backend.StageData;

import shaders.RimlightShader;

import openfl.filters.ShaderFilter;
import openfl.filters.BlurFilter;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;

import flixel.effects.FlxFlicker;

using StringTools;
import lime.app.Application;

import openfl.filters.ShaderFilter;
import openfl.filters.BlurFilter;

import shaders.VCRMario85;
import shaders.ShadersHandler;

#if sys
import sys.FileSystem;
#end

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	public var vcr:VCRMario85;

	var selector:FlxText;
	public static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreMedal:FlxSprite;
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var thatText:FlxText;

	var portrait:FlxSprite;
	var cantDo:Bool = false;

	private var grpSongs:FlxTypedGroup<FlxText>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var rimlight:RimlightShader;

	var bg:FlxSprite;
	public static var intendedColor:Int;
	var colorTween:FlxTween;

	var displayName:String;
	public var medal:FlxSprite;
	
	var hintTxt:FlxText;

	var mainColors:Array<Int> = [
		0xffff0000,
		0xff4d0318,
		0xffff7a00,
		0xffa33917,
		0xffe497de,
		0xfff6ff00,
		0xff33c159,
		0xff000000
	];

	var hints:Array<String> = [
		"It's literally first song lmao",
		"Find THE FIRST ONE in the gallery and press enter",
		"Find the suspicious option in Options menu",
		"Let him make a round 2",
		"Find Yellow and Pink head in Credits Menu",
		"Find Cutie in Hall Of Fame",
		"Get a special note",
		"The Final Song"
	];
	override function create()
	{
		Paths.clearStoredMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		FlxG.camera.bgColor = 0xFF000000; //fuckign dust

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("FREEPLAY", null);
		#end

		addSong('UNFUCKABLE', 0, 'unfuck-pixel', mainColors[0], 'pep-sys', true);
		addSong('Exerection', 0, 'jap-ex-pixel', mainColors[1], 'pep-ex', FlxG.save.data.unlockedSong.contains('exerection'));
		addSong("It's a Me", 0, 'rockie-pixel', mainColors[2], 'huesos', FlxG.save.data.unlockedSong.contains('its-a-me'));
		addSong('Starman Slaughter', 0, 'rockie-pixel', mainColors[3], 'huesos2', FlxG.save.data.unlockedSong.contains('starman-slaughter'));
		addSong('D.E.P', 0, 'dust-pixel', mainColors[4], 'dust', FlxG.save.data.unlockedSong.contains('dep'));
		addSong('CaramellDansen', 0, 'jap-pixel', mainColors[5], 'pep-karamel', FlxG.save.data.unlockedSong.contains('caramelldansen'));
		addSong('Hard Mode', 0, 'news-footbal-pixel', mainColors[6], 'zombies', FlxG.save.data.unlockedSong.contains('hard-mode'));
		if (FlxG.save.data.ending == true) addSong('Holy Hell', 0, 'jap-devil-pixel', mainColors[7], 'pep-devil', true);

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		portrait = new FlxSprite();
		portrait.loadGraphic(Paths.image('freeplay_chars/lamar'));
		portrait.antialiasing = ClientPrefs.data.antialiasing;
		portrait.setPosition(750, 150);
		portrait.updateHitbox();
		portrait.scrollFactor.set();
		add(portrait);

		rimlight = new RimlightShader(315, 10, 0xFFff0000, portrait);
		add(rimlight);
		//portrait.shader = rimlight.shader;

		FlxTween.tween(portrait, {x: 550}, 1, {ease: FlxEase.quadOut});

		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);

		var curID:Int = -1;
		for (i in 0...songs.length)
		{
			curID += 1;
			var songText:FlxText;
			displayName = songs[i].songName;
			if(!FlxG.save.data.playedSongs.contains(Paths.formatToSongPath(songs[i].songName.toLowerCase())))
			{
				var stringArray:Array<String> = displayName.split('');
				displayName = '';
				for (j in stringArray)
				{
					if (j == '-')
						displayName += '-';
					else
						displayName += '?';
				}
			}
			songText = new FlxText(0, 0, 0, displayName, 87);
			songText.setFormat(Paths.font("mariones.ttf"), 57,  FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songText.borderSize = 4;
			songText.ID = curID;
			grpSongs.add(songText);

			songText.scale.x = Math.min(1, 980 / songText.width);

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			// using a FlxGroup is too much fuss!
			if(!FlxG.save.data.playedSongs.contains(Paths.formatToSongPath(songs[i].songName.toLowerCase())))
				if (FlxG.random.bool(0.1))
					icon.animation.curAnim.curFrame = 2;
				else
					icon.animation.curAnim.curFrame = 1;

			iconArray.push(icon);
			add(icon);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.6, 45, 0, "", 24);
		scoreText.setFormat(Paths.font("mariones.ttf"), 24, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 106, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		scoreMedal = new FlxSprite(FlxG.width - 175, 106).makeGraphic(195, 170, 0xFF000000);
		scoreMedal.alpha = 0.6;
		add(scoreMedal);

		add(scoreText);

		// медальки
		medal = new FlxSprite(FlxG.width - 265, -215).loadGraphic(Paths.image('freeplay_medals/medal_7'));
		medal.scale.set(0.2, 0.2);
		medal.updateHitbox();
		medal.antialiasing = ClientPrefs.data.antialiasing;
		medal.visible = true;
		add(medal);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 36).makeGraphic(FlxG.width, 42, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var leText:String = "Press RESET to Reset your Score and Accuracy.";
		var size:Int = 12;
		thatText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		thatText.setFormat(Paths.font("mariones.ttf"), size, FlxColor.WHITE, CENTER);
		thatText.scrollFactor.set();
		add(thatText);

		hintTxt = new FlxText(textBG.x, textBG.y - 42, FlxG.width, hints[curSelected], 24);
		hintTxt.setFormat(Paths.font("mariones.ttf"), 24, FlxColor.WHITE, CENTER);
		hintTxt.scrollFactor.set();
		add(hintTxt);

		changeSelection(0, false);
		changePortrait(songs[curSelected].charPort);
		changeDiff();

		super.create();

		vcr = new VCRMario85();

		if(ClientPrefs.data.tvEffect)
		{
			FlxG.camera.setFilters([ShadersHandler.chromaticAberration, ShadersHandler.radialBlur, new ShaderFilter(vcr)]);
			ShadersHandler.setChrome(0);
		}
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, charPort:String, closed:Bool)
	{
		if(!FlxG.save.data.playedSongs.contains(Paths.formatToSongPath(songName.toLowerCase())))
			color = 0xff737373;

		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, charPort, closed));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		medal.scale.set(
			FlxMath.lerp(medal.scale.x, 0.2, FlxMath.bound(elapsed * 10.2, 0, 1)),
			FlxMath.lerp(medal.scale.y, 0.2, FlxMath.bound(elapsed * 10.2, 0, 1))
		);

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(!cantDo)
		{
			if(songs.length > 1)
			{		
				if (upP)
				{
					changeSelection(-shiftMult);
					changePortrait(songs[curSelected].charPort);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					changePortrait(songs[curSelected].charPort);
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
						changePortrait(songs[curSelected].charPort);
						changeDiff();
					}
				}
		
				if(FlxG.mouse.wheel != 0)
				{
					changeSelection(-FlxG.mouse.wheel);
					changePortrait(songs[curSelected].charPort);
					changeDiff();
				}
			}
		
			if (upP || downP) changeDiff();
		
			if (controls.BACK)
			{
				persistentUpdate = false;
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
				
			if (accepted)
			{
				if (!songs[curSelected].closed == true) return;

				persistentUpdate = false;
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				//trace(poop);

				if (songs[curSelected].songName != 'Holy Hell')
				{
					#if sys
					if(FileSystem.exists(Paths.json(songLowercase + '/' + poop)))
					{
					#end
						PlayState.SONG = Song.loadFromJson(poop, songLowercase);
						PlayState.isStoryMode = false;
						PlayState.storyDifficulty = curDifficulty;
		
						trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
						if(colorTween != null) {
							colorTween.cancel();
						}
							
						FlxG.sound.music.volume = 0;
						cantDo = true;
						destroyFreeplayVocals();
						
						for (i in 0...grpSongs.members.length)
						{
							if (i != curSelected)
							{
								grpSongs.members[i].visible = false;
								iconArray[i].visible = false;
							}
						}
	
						medal.visible = false;
						bg.visible = false;
						scoreText.visible = false;
						thatText.visible = false;
						portrait.visible = false;
	
						new FlxTimer().start(2, function(tmr:FlxTimer)
						{
							FlxG.camera.flash(FlxColor.BLACK, 999); //like what else, better than creating whole graphic
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
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
							});
						});
					#if sys
					} else {
						Application.current.window.alert('Null Song Reference: "' + poop + '". ', "Critical Error!");
					}
					#end
				}
				else
				{
					persistentUpdate = false;
					openSubState(new HardSubState());
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		grpSongs.forEach(function(spr:FlxText)
        {
			var centX = (FlxG.height/2) - (spr.width /2);
            var centY = (FlxG.height/2) - (spr.height /2);
            spr.y = FlxMath.lerp(spr.y, centY - (curSelected-spr.ID) * 200, FlxMath.bound(elapsed * 10, 0, 1));

            var contrY = centX - Math.abs((curSelected-spr.ID))*200;

            spr.x = FlxMath.lerp(spr.x, contrY + 150, FlxMath.bound(elapsed * 10, 0, 1));

            spr.scale.set(
                spr.ID == curSelected ?
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
                    FlxMath.lerp(spr.alpha, 1,FlxMath.bound(elapsed * 5, 0, 1))
                    :
                    FlxMath.lerp(spr.alpha, 0.7, FlxMath.bound(elapsed * 5, 0, 1))
            );
        });


		for (spr in 0...iconArray.length)
        {
            iconArray[spr].scale.set(
                spr == curSelected ?
                    FlxMath.lerp(iconArray[spr].scale.x, 1, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(iconArray[spr].scale.x, 0.8, FlxMath.bound(elapsed * 10.2, 0, 1)),
				spr == curSelected ?
                    FlxMath.lerp(iconArray[spr].scale.x, 1, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(iconArray[spr].scale.x, 0.8, FlxMath.bound(elapsed * 10.2, 0, 1))
            );
            iconArray[spr].alpha = (
				spr == curSelected ?
                    FlxMath.lerp(iconArray[spr].alpha, 1, FlxMath.bound(elapsed * 5, 0, 1))
                    :
                    FlxMath.lerp(iconArray[spr].alpha, 0.6, FlxMath.bound(elapsed * 5, 0, 1))
            );
        };

		if(ClientPrefs.data.tvEffect)
		{
			vcr.update(elapsed);
			ShadersHandler.setChrome(FlxG.random.int(1,3)/1000);
			ShadersHandler.setRadialBlur(640, 360,  FlxG.random.float(0.001, 0.01));
		}

		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		lastDifficultyName = Difficulty.getString(curDifficulty);

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		positionHighscore();

		_updateSongLastDifficulty();
	}

	function uniqueMedalChange(medalInt:Int)
	{
		medal.scale.set(0.4, 0.4);

		medal.loadGraphic(Paths.image('freeplay_medals/medal_'+Highscore.getMedal(songs[curSelected].songName, curDifficulty)));

		if(Highscore.getMedal(songs[curSelected].songName, curDifficulty) == 1)
		{
			medal.offset.x = 75;
			medal.offset.y = 0;
		}
		else if(Highscore.getMedal(songs[curSelected].songName, curDifficulty) == 2)
		{
			medal.offset.x = 25;
			medal.offset.y = 15;
		}
		else
		{
			medal.offset.x = 0;
			medal.offset.y = 0;
		}
	}

	var portTween:FlxTween;
	function changePortrait(char:String = 'lamar')
	{
		portrait.loadGraphic(Paths.image('freeplay_chars/'+char));

		if(!FlxG.save.data.playedSongs.contains(Paths.formatToSongPath(songs[curSelected].songName.toLowerCase())))
		{
			portrait.shader = rimlight.shader;
			portrait.color = 0xff000000;
		}
		else
		{
			portrait.shader = null;
			portrait.color = 0xffffffff;
		}

		switch(char)
		{
			case 'pep-sys':
				portrait.offset.set(0, 200);
			case 'pep-ex':
				portrait.offset.set(0, 150);
			case 'huesos2':
				portrait.offset.set(0, -10);
			case 'dust':
				portrait.offset.set(0, 200);
			case 'zombies':
				portrait.offset.set(-127, 0);
			case 'pep-devil':
				portrait.offset.set(0, 150);
			default:
				portrait.offset.set(0, 0);
		}
		if(portTween != null) portTween.cancel();
		portrait.y == 150;
		portrait.y += 30;
		portTween = FlxTween.tween(portrait, {y: 150}, 0.3, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
            {
                portTween = null;
            }});
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var lastList:Array<String> = Difficulty.list;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		hintTxt.text = hints[curSelected];
		hintTxt.visible = !songs[curSelected].closed;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		Difficulty.resetList();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();

		uniqueMedalChange(Highscore.getMedal(songs[curSelected].songName, curDifficulty));
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
	}

	inline private function _updateSongLastDifficulty()
	{
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var charPort:String = "";
	public var closed:Bool = false;
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int, charPort:String, closed:Bool)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.charPort = charPort;
		this.closed = closed;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}