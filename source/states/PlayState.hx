package states;

import backend.Highscore;
import backend.StageData;
import backend.WeekData;
import backend.Song;
import backend.Rating;
import haxe.Int64;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import lime.app.Application;
import openfl.Lib;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimationController;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.events.KeyboardEvent;
import haxe.Json;

import cutscenes.DialogueBoxPsych;

import states.editors.ChartingState;
import states.editors.CharacterEditorState;

import substates.PauseSubState;
import substates.PauseSubStateOld;
import substates.GameOverSubstate;

#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

import objects.VideoSprite;

import objects.Note.EventNote;
import objects.*;
import states.stages.*;
import states.stages.objects.*;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
#end

/**
 * This is where all the Gameplay stuff happens and is managed
 *
 * here's some useful tips if you are making a mod in source:
 *
 * If you want to add your stage to the game, copy states/stages/Template.hx,
 * and put your stage code there, then, on PlayState, search for
 * "switch (curStage)", and add your stage to that list.
 *
 * If you want to code Events, you can either code it on a Stage file or on PlayState, if you're doing the latter, search for:
 *
 * "function eventPushed" - Only called *one time* when the game loads, use it for precaching events that use the same assets, no matter the values
 * "function eventPushedUnique" - Called one time per event, use it for precaching events that uses different assets based on its values
 * "function eventEarlyTrigger" - Used for making your event start a few MILLISECONDS earlier
 * "function triggerEvent" - Called when the song hits your event's timestamp, this is probably what you were looking for
**/
class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var momMap:Map<String, Character> = new Map<String, Character>();
	public var broMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var MOM_X:Float = 100;
	public var MOM_Y:Float = 100;
	public var BRO_X:Float = 100;
	public var BRO_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var momGroup:FlxSpriteGroup;
	public var broGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var stageUI(default, set):String = "normal";
	public static var uiPrefix:String = "";
	public static var uiPostfix:String = "";
	public static var isPixelStage(get, never):Bool;

	var initScroll:Bool;

	@:noCompletion
	static function set_stageUI(value:String):String
	{
		uiPrefix = uiPostfix = "";
		if (value != "normal")
		{
			uiPrefix = value.split("-pixel")[0].trim();
			if (value == "pixel" || value.endsWith("-pixel")) uiPostfix = "-pixel";
		}
		return stageUI = value;
	}

	@:noCompletion
	static function get_isPixelStage():Bool
		return stageUI == "pixel" || stageUI.endsWith("-pixel");

	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var opponentVocals:FlxSound;
	public var beatusVocals:FlxSound;

	public var dad:Character = null;
	public var mom:Character = null;
	public var bro:Character = null;
	public var gf:Character = null;
	public var boyfriend:Character = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	public var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	var cameraFollowPoint:FlxObject = new FlxObject();
	var followCharacter:Bool = false;
    var nOffset:Float = 30;
	
	var cameraFollowTween:FlxTween;
	var cameraZoomTween:FlxTween;

	public var currentCameraZoom:Float = 1.0;
	var cameraBopMultiplier:Float = 1.0;

	var defaultHUDCameraZoom:Float = 1.0;
	var cameraBopIntensity:Float = 1.015;
	var hudCameraZoomIntensity:Float = 0.015 * 2.0;
	var cameraZoomRate:Int = 4;

	var directionFade:Bool = true; //fade camera

	private var task:SongIntro;

	public var strumLineNotes:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
	public var opponentStrums:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
	public var playerStrums:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash> = new FlxTypedGroup<NoteSplash>();
	public var grpHoldSplashes:FlxTypedGroup<SustainSplash>;

	private var curSong:String = "";

	public var ghostToggle:Bool = false;
	var left:Bool = true;

	private var singingShakeArray:Array<Bool> = [false, false];
	private var opponentHealthDrain:Bool = false;
	private var opponentHealthDrainAmount:Float = 0.023;

	public var goHealthDamageBeat:Bool = false;
	public var beatHealthDrain:Float = 0.023; //mb can be good???
	public var beatHealthStep:Int = 4;

	public var gfSpeed:Int = 1;
	public var health(default, set):Float = 1;
	public var smoothHealth:Float = 1;
	public var combo:Int = 0;

	public var healthBar:Bar;
	public var timeBar:Bar;
	private var healthBarBGOverlay:FlxSprite;
	var songPercent:Float = 0;

	private var fireHalapeno:FlxSprite;
	private var fireFlash:FlxSprite;

	public var ratingsData:Array<Rating> = Rating.loadDefault();

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	public var ycfu:Bool = false;
	public var ycfu2:Bool = false;

	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;
	public var pressMissDamage:Float = 0.05;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	var ycbuIconPos1 = new FlxPoint(0, 0);
	var ycbuIconPos2 = new FlxPoint(-85, 50);
	var ycbuIconPos3 = new FlxPoint(-85, -50);

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var iconPEP:HealthIcon;
	public var iconPOLE:HealthIcon;
	public var iconJACK:HealthIcon;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var camHudBehind:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;
	var ratingTxt:FlxText;
	var accuracyShit:FlxText;

	var topBar:FlxSprite;
	var bottomBar:FlxSprite;

	var shakeBeat = false;

	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	//LANES
	var laneP0:FlxSprite;
	var laneP1:FlxSprite;
	var laneP2:FlxSprite;
	var laneP3:FlxSprite;

	var laneE0:FlxSprite;
	var laneE1:FlxSprite;
	var laneE2:FlxSprite;
	var laneE3:FlxSprite;

	public static var respawnPoint:Int = 0;
	public static var respawned:Bool = false;

	public var defaultCamZoom:Float = 1.05;
	var stageZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;
	var songLengthDiscord:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if DISCORD_ALLOWED
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//ZONDRIE MECHA
	var wave2Zom:FlxSprite;
	var eatin:Bool = false;
	var speedEater:Int = 8;
	var whenEat:Int = 0;

	var jacksonDrain:FlxSprite;
	var jackTime:FlxTimer;

	// Lua shit
	public static var instance:PlayState;
	#if LUA_ALLOWED public var luaArray:Array<FunkinLua> = []; #end

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	private var luaDebugGroup:FlxTypedGroup<psychlua.DebugLuaText>;
	#end
	public var introSoundsSuffix:String = '';

	// Less laggy controls
	private var keysArray:Array<String>;
	public var songName:String;

	//video var
	//public var sequence2:VideoSprite = null;
	public var sequences:VideoSprite = null;
	var hypnoBg:VideoSprite = null;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;

	private static var _lastLoadedModDirectory:String = '';
	public static var nextReloadAll:Bool = false;
	override public function create()
	{
		//trace('Playback Rate: ' + playbackRate);
		_lastLoadedModDirectory = Mods.currentModDirectory;
		Paths.clearStoredMemory();
		if(nextReloadAll)
		{
			Paths.clearUnusedMemory();
			Language.reloadPhrases();
		}
		nextReloadAll = false;

		startCallback = startCountdown;
		endCallback = endSong;

		// for lua
		instance = this;

		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed');

		keysArray = [
			'note_left',
			'note_down',
			'note_up',
			'note_right'
		];

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camera.angle = 0;

		// Gameplay settings
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill');
		practiceMode = ClientPrefs.getGameplaySetting('practice');
		cpuControlled = ClientPrefs.getGameplaySetting('botplay');

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = initPsychCamera();
		camHudBehind = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		camHudBehind.bgColor.alpha = 0;

		FlxG.cameras.add(camHudBehind, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpHoldSplashes = new FlxTypedGroup<SustainSplash>();

		persistentUpdate = true;
		persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;

		#if DISCORD_ALLOWED
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		storyDifficultyText = Difficulty.getString();

		if (isStoryMode)
			detailsText = "YOU CANNOT FUCK US";
		else
			detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		topBar = new FlxSprite(0, -170).makeGraphic(1280, 170, FlxColor.BLACK);
		bottomBar = new FlxSprite(0, 720).makeGraphic(1280, 170, FlxColor.BLACK);

		GameOverSubstate.resetVariables();
		songName = Paths.formatToSongPath(SONG.song);
		if(SONG.stage == null || SONG.stage.length < 1)
			SONG.stage = StageData.vanillaSongStage(Paths.formatToSongPath(Song.loadedSongName));

		curStage = SONG.stage;

		if(SONG.song == 'ezqsvf') //лучше так чем графику создавать ЛОЛ
			camGame.bgColor = 0xFFFFFFFF;
		else
			camGame.bgColor = 0xFF000000;

		var stageData:StageFile = StageData.getStageFile(curStage);
		defaultCamZoom = stageData.defaultZoom;
		stageZoom = stageData.defaultZoom;

		stageUI = "normal";
		if (stageData.stageUI != null && stageData.stageUI.trim().length > 0)
			stageUI = stageData.stageUI;
		else if (stageData.isPixelStage == true) //Backward compatibility
			stageUI = "pixel";

		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		BRO_X = stageData.opponent[0];
		BRO_Y = stageData.opponent[1];
		MOM_X = stageData.opponent[0];
		MOM_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		momGroup = new FlxSpriteGroup(MOM_X, MOM_Y);
		broGroup = new FlxSpriteGroup(BRO_X, BRO_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		if(!ClientPrefs.data.optimize)
		{
			switch (curStage)
			{
				case 'stage': new StageWeek1(); 			//Week 1
				case 'nesbeat': new Nesbeat(); 			    //База
			}
		}

		if(isPixelStage) introSoundsSuffix = '-pixel';

		if (!ClientPrefs.data.lowQuality && !ClientPrefs.data.optimize)
		{
			if(ClientPrefs.data.flashing)
			{
				if(SONG.song == 'UNFUCKABLE')
				{
					hypnoBg = new VideoSprite(Paths.video('hypno bg'), true, false, true, false);
					add(hypnoBg);
					hypnoBg.play();
					hypnoBg.videoSprite.setGraphicSize(FlxG.width * 2, FlxG.height * 2);
					hypnoBg.alpha = 0.4;
					//hypnoBg.blend = MULTIPLY;
					hypnoBg.videoSprite.cameras = [camGame];
					hypnoBg.visible = false;
				}
			}
		}

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		luaDebugGroup = new FlxTypedGroup<psychlua.DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		if (!stageData.hide_girlfriend && !ClientPrefs.data.optimize)
		{
			if(SONG.gfVersion == null || SONG.gfVersion.length < 1) SONG.gfVersion = 'gf'; //Fix for the Chart Editor
			gf = new Character(0, 0, SONG.gfVersion);
			startCharacterPos(gf);
			gfGroup.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
		}

		mom = new Character(0, 0, 'unfuck_pole');
		startCharacterPos(mom, true);
		if(SONG.song != 'UNFUCKABLE') mom.visible = false;
		momGroup.add(mom);

		bro = new Character(0, 0, 'unfuck_jack');
		startCharacterPos(bro, true);
		if(SONG.song != 'UNFUCKABLE') bro.visible = false;
		broGroup.add(bro);

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);

		boyfriend = new Character(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		
		if(stageData.objects != null && stageData.objects.length > 0)
		{
			var list:Map<String, FlxSprite> = StageData.addObjectsToState(stageData.objects, !stageData.hide_girlfriend ? gfGroup : null, dadGroup, boyfriendGroup, this);
			for (key => spr in list)
				if(!StageData.reservedNames.contains(key))
					variables.set(key, spr);
		}
		else
		{
			add(gfGroup);
			add(momGroup);
			add(broGroup);
			add(dadGroup);
			add(boyfriendGroup);
		}
		
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		// "SCRIPTS FOLDER" SCRIPTS
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end
			
		resetCamera();
		
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		// STAGE SCRIPTS
		#if LUA_ALLOWED startLuasNamed('stages/' + curStage + '.lua'); #end
		#if HSCRIPT_ALLOWED startHScriptsNamed('stages/' + curStage + '.hx'); #end

		// CHARACTER SCRIPTS
		if(gf != null) startCharacterScripts(gf.curCharacter);
		startCharacterScripts(dad.curCharacter);
		startCharacterScripts(boyfriend.curCharacter);
		#end

		if(ClientPrefs.data.optimize)
		{
			boyfriendGroup.alpha = 0.00001;
			dadGroup.alpha = 0.00001;
			broGroup.alpha = 0.00001;
			momGroup.alpha = 0.00001;
			gfGroup.alpha = 0.00001;
		}

		uiGroup = new FlxSpriteGroup();
		comboGroup = new FlxSpriteGroup();
		noteGroup = new FlxTypedGroup<FlxBasic>();
		add(comboGroup);
		add(uiGroup);
		add(noteGroup);

		createLanes();

		Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;
		var showTime:Bool = (ClientPrefs.data.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("HouseofTerror.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = updateTime = showTime;
		if(ClientPrefs.data.downScroll) timeTxt.y = FlxG.height - 44;
		if(ClientPrefs.data.timeBarType == 'Song Name') timeTxt.text = SONG.song;

		timeBar = new Bar(0, timeTxt.y + (timeTxt.height / 4) - 9, 'timeBar', function() return songPercent, 0, 1);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		timeBar.setColors(0xffc3e942, 0xff000000);
		uiGroup.add(timeBar);
		uiGroup.add(timeTxt);

		noteGroup.add(strumLineNotes);

		if(ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		SustainSplash.startCrochet = Conductor.stepCrochet;
		SustainSplash.frameRate = Math.floor(24 / 100 * SONG.bpm);
		var splash:SustainSplash = new SustainSplash();
		grpHoldSplashes.add(splash);
		splash.alpha = 0.0001;

		generateSong();

		noteGroup.add(grpHoldSplashes);
		noteGroup.add(grpNoteSplashes);

		camFollow = new FlxObject();
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.snapToTarget();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		moveCameraSection();

		healthBarBGOverlay = new FlxSprite(0, 0);
		healthBarBGOverlay.loadGraphic(Paths.image('healthBarBG', 'shared'));
		healthBarBGOverlay.visible = !ClientPrefs.data.hideHud;
		healthBarBGOverlay.alpha = ClientPrefs.data.healthBarAlpha;
		healthBarBGOverlay.antialiasing = false;
		uiGroup.add(healthBarBGOverlay);

		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBar', function() return smoothHealth, 0, 2);
		healthBar.screenCenter(X);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.data.hideHud;
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;
		reloadHealthBarColors();
		uiGroup.add(healthBar);

		healthBarBGOverlay.x = healthBar.x - 22;
		healthBarBGOverlay.y = healthBar.y - 38;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.data.hideHud;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.data.hideHud;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP2);

		iconPEP = new HealthIcon(dad.healthIcon, false);
		iconPEP.y = healthBar.y - 75;
		iconPEP.visible = !ClientPrefs.data.hideHud;
		iconPEP.alpha = 0;
		uiGroup.add(iconPEP);

		iconPOLE = new HealthIcon('poolwalter', false);
		iconPOLE.y = healthBar.y - 75;
		iconPOLE.visible = !ClientPrefs.data.hideHud;
		iconPOLE.alpha = 0;
		uiGroup.add(iconPOLE);

		iconJACK = new HealthIcon('dance', false);
		iconJACK.y = healthBar.y - 75;
		iconJACK.visible = !ClientPrefs.data.hideHud;
		iconJACK.alpha = 0;
		uiGroup.add(iconJACK);

		ycbuIconPos1 = new FlxPoint(0, 0);
		ycbuIconPos2 = new FlxPoint(-85, 50);
		ycbuIconPos3 = new FlxPoint(-85, -50);

		wave2Zom = new FlxSprite(iconP2.x, /*iconP2.y - 100*/ iconP2.y + 250);
		wave2Zom.frames = Paths.getSparrowAtlas('wave2/zombieEater', 'death');
		wave2Zom.antialiasing = ClientPrefs.data.antialiasing;
		wave2Zom.flipX = true;
		wave2Zom.animation.addByPrefix('idle', 'zombie walk', 17, true);
		wave2Zom.animation.addByPrefix('eat', 'zombie eat', 40, true);
		wave2Zom.animation.play('idle');
		wave2Zom.scale.set(2, 2);

		if(ClientPrefs.data.downScroll) wave2Zom.y = iconP2.y - 250;

		uiGroup.add(wave2Zom);

		jacksonDrain = new FlxSprite(-500, iconP2.y + 15);
		jacksonDrain.frames = Paths.getSparrowAtlas('wave3/jacksonWalkBald', 'death');
		jacksonDrain.antialiasing = ClientPrefs.data.antialiasing;
		//jacksonDrain.flipX = true;
		jacksonDrain.animation.addByPrefix('idle', 'jackson', 30, true);
		jacksonDrain.animation.play('idle');
		jacksonDrain.scale.set(2, 2);
		uiGroup.add(jacksonDrain);

		scoreTxt = new FlxText(0, 0, FlxG.width, "", 32);
		scoreTxt.setFormat(Paths.font("HouseofTerror.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.screenCenter(Y);
		scoreTxt.visible = !ClientPrefs.data.hideHud;
		uiGroup.add(scoreTxt);

		accuracyShit = new FlxText(0, healthBar.y + 40, FlxG.width, "Rating: Horny", 32);
		accuracyShit.setFormat(Paths.font("HouseofTerror.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		accuracyShit.scrollFactor.set();
		accuracyShit.borderSize = 1.25;

		if(ClientPrefs.data.downScroll) accuracyShit.y = healthBar.y - 70;
		uiGroup.add(accuracyShit);

		ratingTxt = new FlxText(0, healthBar.y - 125, FlxG.width, "Lmao x69", 64);
		ratingTxt.setFormat(Paths.font("HouseofTerror.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		ratingTxt.scrollFactor.set();
		ratingTxt.alpha = 0.001;
		ratingTxt.borderSize = 1.5;

		if(ClientPrefs.data.downScroll) ratingTxt.y = healthBar.y + 100;
		uiGroup.add(ratingTxt);

		/*sequence2 = new VideoSprite(Paths.video('sequence 2'), true, false, false, false);
		sequence2.videoSprite.bitmap.rate = playbackRate;
		add(sequence2);
		sequence2.videoSprite.cameras = [camHudBehind];*/

		if (!ClientPrefs.data.lowQuality)
		{
			if(SONG.song == 'UNFUCKABLE' && !ClientPrefs.data.optimize)
			{
				sequences = new VideoSprite(Paths.video('sequences'), true, false, false, false);
				sequences.videoSprite.bitmap.rate = playbackRate;
				add(sequences);
				sequences.videoSprite.cameras = [camHudBehind];
				sequences.play();
				sequences.alpha = 0.0001;
			}
			fireHalapeno = new FlxSprite(0, scoreTxt.y - 150);
			fireHalapeno.frames = Paths.getSparrowAtlas('fire_jap');
			fireHalapeno.animation.addByPrefix('idle', 'firing', 24, false);
			fireHalapeno.flipY = ClientPrefs.data.downScroll;
			fireHalapeno.antialiasing = ClientPrefs.data.antialiasing;
			fireHalapeno.scrollFactor.set();
			fireHalapeno.blend = ADD;
			fireHalapeno.alpha = 0.0001;
			fireHalapeno.updateHitbox();
			fireHalapeno.screenCenter(X);
			fireHalapeno.animation.play('idle');
			uiGroup.add(fireHalapeno);

			if(ClientPrefs.data.downScroll)
				fireHalapeno.y = -25;
		}

		fireFlash = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFFF7700);
		fireFlash.alpha = 0.001;
		fireFlash.blend = ADD;
		uiGroup.add(fireFlash);

		botplayTxt = new FlxText(400, healthBar.y - 90, FlxG.width - 800, Language.getPhrase("Botplay").toUpperCase(), 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		uiGroup.add(botplayTxt);
		if(ClientPrefs.data.downScroll)
			botplayTxt.y = healthBar.y + 70;

		uiGroup.cameras = [camHUD];
		noteGroup.cameras = [camHUD];
		comboGroup.cameras = [camHUD];

		startingSong = true;

		#if LUA_ALLOWED
		for (notetype in noteTypes)
			startLuasNamed('custom_notetypes/' + notetype + '.lua');
		for (event in eventsPushed)
			startLuasNamed('custom_events/' + event + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		for (notetype in noteTypes)
			startHScriptsNamed('custom_notetypes/' + notetype + '.hx');
		for (event in eventsPushed)
			startHScriptsNamed('custom_events/' + event + '.hx');
		#end
		noteTypes = null;
		eventsPushed = null;

		if(eventNotes.length > 1)
		{
			for (event in eventNotes) event.strumTime -= eventEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		// SONG SPECIFIC SCRIPTS
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/$songName/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		setupCameraToSong();
		resetCamera();

		startCallback();
		RecalculateRating(false, false);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		//PRECACHING THINGS THAT GET USED FREQUENTLY TO AVOID LAGSPIKES
		if(ClientPrefs.data.hitsoundVolume > 0) Paths.sound('hitsound');
		if(!ClientPrefs.data.ghostTapping) for (i in 1...4) Paths.sound('missnote$i');
		Paths.image('alphabet');

		if (PauseSubState.songName != null)
			Paths.music(PauseSubState.songName);
		else if(Paths.formatToSongPath(ClientPrefs.data.pauseMusic) != 'none')
			Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic));

		if(PlayState.SONG.song == 'UNFUCKABLE')
		{
			Paths.music('UBstart');
			Paths.music('UBloop');
		}

		resetRPC();

		initScroll = ClientPrefs.data.downScroll;

		stagesFunc(function(stage:BaseStage) stage.createPost());
		callOnScripts('onCreatePost');

		Init.fog = false;
		
		var splash:NoteSplash = new NoteSplash();
		grpNoteSplashes.add(splash);
		splash.alpha = 0.000001; //cant make it invisible or it won't allow precaching

		super.create();
		Paths.clearUnusedMemory();

		cacheCountdown();
		cachePopUpScore();

		if(eventNotes.length < 1) checkEventNote();
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		songSpeed = value;
		noteKillOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		#if FLX_PITCH
		if(generatedMusic)
		{
			vocals.pitch = value;
			opponentVocals.pitch = value;
			if(songName == 'unfuckable') beatusVocals.pitch = value;
			FlxG.sound.music.pitch = value;

			var ratio:Float = playbackRate / value; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		playbackRate = value;
		FlxG.animationTimeScale = value;
		Conductor.offset = Reflect.hasField(PlayState.SONG, 'offset') ? (PlayState.SONG.offset / value) : 0;
		Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
		if(videoCutscene != null) videoCutscene.videoSprite.bitmap.rate = value;
		//if(sequence2 != null) sequence2.videoSprite.bitmap.rate = value;
		if(sequences != null) sequences.videoSprite.bitmap.rate = value;
		setOnScripts('playbackRate', playbackRate);
		#else
		playbackRate = 1.0; // ensuring -Crow
		#end
		return playbackRate;
	}

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public function addTextToDebug(text:String, color:FlxColor) {
		var newText:psychlua.DebugLuaText = luaDebugGroup.recycle(psychlua.DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:psychlua.DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);

		Sys.println(text);
	}
	#end

	public function reloadHealthBarColors(?other:String) {
		switch(other)
		{
			case 'pole':
				healthBar.setColors(FlxColor.fromRGB(mom.healthColorArray[0], mom.healthColorArray[1], mom.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
			case 'jackson':
				healthBar.setColors(FlxColor.fromRGB(bro.healthColorArray[0], bro.healthColorArray[1], bro.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
			case 'nothing':
				healthBar.setColors(FlxColor.fromRGB(0, 0, 0),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
			default:
				healthBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		}
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterScripts(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterScripts(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterScripts(newGf.curCharacter);
				}

			case 3:
				if(!momMap.exists(newCharacter)) {
					var newMom:Character = new Character(0, 0, newCharacter);
					momMap.set(newCharacter, newMom);
					momGroup.add(newMom);
					startCharacterPos(newMom, true);
					newMom.alpha = 0.00001;
					startCharacterScripts(newMom.curCharacter);
				}

			case 4:
				if(!broMap.exists(newCharacter)) {
					var newBro:Character = new Character(0, 0, newCharacter);
					broMap.set(newCharacter, newBro);
					broGroup.add(newBro);
					startCharacterPos(newBro, true);
					newBro.alpha = 0.00001;
					startCharacterScripts(newBro.curCharacter);
				}
		}
	}

	function startCharacterScripts(name:String)
	{
		// Lua
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/$name.lua';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(luaFile);
		if(FileSystem.exists(replacePath))
		{
			luaFile = replacePath;
			doPush = true;
		}
		else
		{
			luaFile = Paths.getSharedPath(luaFile);
			if(FileSystem.exists(luaFile))
				doPush = true;
		}
		#else
		luaFile = Paths.getSharedPath(luaFile);
		if(Assets.exists(luaFile)) doPush = true;
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile)
				{
					doPush = false;
					break;
				}
			}
			if(doPush) new FunkinLua(luaFile);
		}
		#end

		// HScript
		#if HSCRIPT_ALLOWED
		var doPush:Bool = false;
		var scriptFile:String = 'characters/' + name + '.hx';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(scriptFile);
		if(FileSystem.exists(replacePath))
		{
			scriptFile = replacePath;
			doPush = true;
		}
		else
		#end
		{
			scriptFile = Paths.getSharedPath(scriptFile);
			if(FileSystem.exists(scriptFile))
				doPush = true;
		}

		if(doPush)
		{
			if(Iris.instances.exists(scriptFile))
				doPush = false;

			if(doPush) initHScript(scriptFile);
		}
		#end
	}

	public function getLuaObject(tag:String):Dynamic
		return variables.get(tag);

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public var videoCutscene:VideoSprite = null;
	public function startVideo(name:String, forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false, playOnLoad:Bool = true)
	{
		#if VIDEOS_ALLOWED
		inCutscene = !forMidSong;
		canPause = forMidSong;

		var foundFile:Bool = false;
		var fileName:String = Paths.video(name);

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			videoCutscene = new VideoSprite(fileName, forMidSong, canSkip, loop, false);
			videoCutscene.videoSprite.bitmap.rate = playbackRate;

			// Finish callback
			if (!forMidSong)
			{
				function onVideoEnd()
				{
					if (!isDead && generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong)
					{
						moveCameraSection();
						FlxG.camera.snapToTarget();
					}
					videoCutscene = null;
					canPause = true;
					inCutscene = false;
					startAndEnd();
				}
				videoCutscene.finishCallback = onVideoEnd;
				videoCutscene.onSkip = onVideoEnd;
			}
			if (GameOverSubstate.instance != null && isDead) GameOverSubstate.instance.add(videoCutscene);
			else add(videoCutscene);

			videoCutscene.videoSprite.cameras = [cameraFromString('video')];

			if (playOnLoad)
				videoCutscene.play();
			return videoCutscene;
		}
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		else addTextToDebug("Video not found: " + fileName, FlxColor.RED);
		#else
		else FlxG.log.error("Video not found: " + fileName);
		#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		#end
		return null;
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')))" and it should load dialogue.json
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			startAndEnd();
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;
	public static var wasStartedOn:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		var introImagesArray:Array<String> = switch(stageUI) {
			case "pixel": ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel'];
			case "normal": ["ready", "set" ,"go", "finalwave", "wave"];
			default: ['${uiPrefix}UI/ready${uiPostfix}', '${uiPrefix}UI/set${uiPostfix}', '${uiPrefix}UI/go${uiPostfix}'];
		}
		introAssets.set(stageUI, introImagesArray);
		var introAlts:Array<String> = introAssets.get(stageUI);
		for (asset in introAlts) Paths.image(asset);

		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown()
	{
		if(startedCountdown) {
			callOnScripts('onStartCountdown');
			return false;
		}

		seenCutscene = true;
		inCutscene = false;
		var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
		if(ret != LuaUtils.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			canPause = true;
			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnScripts('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnScripts('defaultPlayerStrumY' + i, playerStrums.members[i].y);

				setOnScripts('initDefaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnScripts('initDefaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnScripts('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnScripts('defaultOpponentStrumY' + i, opponentStrums.members[i].y);

				setOnScripts('initDefaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnScripts('initDefaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.data.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;
			setOnScripts('startedCountdown', true);
			callOnScripts('onCountdownStarted');

			var swagCounter:Int = 0;
			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return true;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return true;
			}
			moveCameraSection();

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				characterBopper(tmr.loopsLeft);

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				var introImagesArray:Array<String> = switch(stageUI) {
					case "pixel": ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel'];
					case "normal": ["ready", "set" ,"go"];
					default: ['${uiPrefix}UI/ready${uiPostfix}', '${uiPrefix}UI/set${uiPostfix}', '${uiPrefix}UI/go${uiPostfix}'];
				}
				introAssets.set(stageUI, introImagesArray);

				var introAlts:Array<String> = introAssets.get(stageUI);
				var antialias:Bool = (ClientPrefs.data.antialiasing && !isPixelStage);
				var tick:Countdown = THREE;

				switch (swagCounter)
				{
					case 0:
						if(Init.fun >= 0 && Init.fun <= 24) FlxG.sound.play(Paths.sound('pp3'), 0.6);
						tick = THREE;
					case 1:
						if(Init.fun >= 0 && Init.fun <= 24) FlxG.sound.play(Paths.sound('pp2'), 0.6);
						tick = TWO;
					case 2:
						if(Init.fun >= 0 && Init.fun <= 24) FlxG.sound.play(Paths.sound('pp1'), 0.6);
						tick = ONE;
					case 3:
						if(Init.fun >= 0 && Init.fun <= 24) FlxG.sound.play(Paths.sound('pp0'), 0.6);
						tick = GO;
					case 4:
						if(Init.fun >= 0 && Init.fun <= 24) Init.fun = -1;
						tick = START;
				}

				if(!skipArrowStartTween)
				{
					notes.forEachAlive(function(note:Note) {
						if(ClientPrefs.data.opponentStrums || note.mustPress)
						{
							note.copyAlpha = false;
							note.alpha = note.multAlpha;
							if(ClientPrefs.data.middleScroll && !note.mustPress)
								note.alpha *= 0.35;
						}
					});
				}

				stagesFunc(function(stage:BaseStage) stage.countdownTick(tick, swagCounter));
				callOnLuas('onCountdownTick', [swagCounter]);
				callOnHScript('onCountdownTick', [tick, swagCounter]);

				swagCounter += 1;
			}, 5);
		}
		return true;
	}

	inline private function createCountdownSprite(image:String, antialias:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		spr.cameras = [camHUD];
		spr.scrollFactor.set();
		spr.updateHitbox();

		if (PlayState.isPixelStage)
			spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.screenCenter();
		spr.antialiasing = antialias;
		insert(members.indexOf(noteGroup), spr);
		FlxTween.tween(spr, {/*y: spr.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				remove(spr);
				spr.destroy();
			}
		});
		return spr;
	}

	public function addBehindGF(obj:FlxBasic)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxBasic)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad(obj:FlxBasic)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				invalidateNote(daNote);
			}
			--i;
		}
	}

	// fun fact: Dynamic Functions can be overriden by just doing this
	// `updateScore = function(miss:Bool = false) { ... }
	// its like if it was a variable but its just a function!
	// cool right? -Crow
	public dynamic function updateScore(miss:Bool = false, scoreBop:Bool = true)
	{
		var ret:Dynamic = callOnScripts('preUpdateScore', [miss], true);
		if (ret == LuaUtils.Function_Stop)
			return;

		updateScoreText();
		if (!miss && !cpuControlled && scoreBop) doScoreBop();

		callOnScripts('onUpdateScore', [miss]);
	}

	public dynamic function updateScoreText()
	{
		var str:String = '?';
		if(totalPlayed != 0)
		{
			var percent:Float = CoolUtil.floorDecimal(ratingPercent * 100, 2);
			str = ' ($percent%) - $ratingFC';
		}

		var tempScore:String;

		if(instakillOnMiss)
		{
			tempScore = 'Score: ' + FlxStringUtil.formatMoney(songScore, false, true)
			+ '\nAccuracy: ' + str
			+ '\nMisses: DON\'T MISS';
		}
		else if(ycfu)
		{
			tempScore = 'YOU CANNOT: ' + FlxStringUtil.formatMoney(songScore, false, true)
			+ '\nFUCK: ' + str
			+ '\nUS: ' + songMisses;
		}
		else
		{
			tempScore = 'Score: ' + FlxStringUtil.formatMoney(songScore, false, true)
			+ '\nAccuracy: ' + str
			+ '\nMisses: ' + songMisses;
		}

		if(ycfu2)
			accuracyShit.text = 'YOU CANNOT FUCK US: ' + ratingName;
		else
			accuracyShit.text = 'Rating: ' + ratingName;

		scoreTxt.text = tempScore;
	}

	public dynamic function fullComboFunction()
	{
		var sicks:Int = ratingsData[0].hits;
		var goods:Int = ratingsData[1].hits;
		var bads:Int = ratingsData[2].hits;
		var shits:Int = ratingsData[3].hits;

		ratingFC = "";
		if(songMisses == 0)
		{
			if (bads > 0 || shits > 0) ratingFC = 'FC';
			else if (goods > 0) ratingFC = 'GFC';
			else if (sicks > 0) ratingFC = 'SFC';
		}
		else {
			if (songMisses < 10) ratingFC = 'SDCB';
			else ratingFC = 'Clear';
		}
	}

	public function doScoreBop():Void {
		if(!ClientPrefs.data.scoreZoom)
			return;

		if(scoreTxtTween != null)
			scoreTxtTween.cancel();

		accuracyShit.scale.x = 1.075;
		accuracyShit.scale.y = 1.075;
		scoreTxtTween = FlxTween.tween(accuracyShit.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				scoreTxtTween = null;
			}
		});
	}

	private inline static var MAX_32_PRECISION = 4294967296;

	public static function fromFloat(f:Float):Int64 { //на нах
		return Int64.make(Std.int(f/MAX_32_PRECISION), Std.int(f-(f/MAX_32_PRECISION)));
	}

	public static function toFloat(i:Int64):Float {

		return (Int64.getHigh(i) * MAX_32_PRECISION + Int64.getLow(i));
	}

	public function setSongTime(time:Float)
	{
		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();
		if(songName == 'unfuckable') beatusVocals.pause();

		if(sequences != null) sequences.videoSprite.bitmap.time = fromFloat(time);

		FlxG.sound.music.time = time - Conductor.offset;
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.play();

		if (Conductor.songPosition < vocals.length)
		{
			vocals.time = time - Conductor.offset;
			#if FLX_PITCH vocals.pitch = playbackRate; #end
			vocals.play();
		}
		else vocals.pause();

		if (Conductor.songPosition < opponentVocals.length)
		{
			opponentVocals.time = time - Conductor.offset;
			#if FLX_PITCH opponentVocals.pitch = playbackRate; #end
			opponentVocals.play();
		}
		else opponentVocals.pause();

		if(songName == 'unfuckable')
		{
			if (Conductor.songPosition < beatusVocals.length)
			{
				beatusVocals.time = time - Conductor.offset;
				#if FLX_PITCH beatusVocals.pitch = playbackRate; #end
				beatusVocals.play();
			}
			else beatusVocals.pause();
		}

		Conductor.songPosition = time;
	}

	public function startNextDialogue() {
		dialogueCount++;
		callOnScripts('onNextDialogue', [dialogueCount]);
	}

	public function skipDialogue() {
		callOnScripts('onSkipDialogue', [dialogueCount]);
	}

	var finishLength:Float;
	function startSong():Void
	{
		startingSong = false;

		@:privateAccess
		FlxG.sound.playMusic(inst._sound, 1, false);
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		if(songName == 'unfuckable') beatusVocals.play();
		opponentVocals.play();

		setSongTime(Math.max(0, startOnTime - 500) + Conductor.offset);
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
			if(songName == 'unfuckable') beatusVocals.pause();
		}

		stagesFunc(function(stage:BaseStage) stage.startSong());

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		songLengthDiscord = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence (with Time Left)
		if(autoUpdateRPC) DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLengthDiscord);
		#end
		finishLength = songLength - 1000;
		setOnScripts('songLength', songLength);
		callOnScripts('onSongStart');
	}

	private var noteTypes:Array<String> = [];
	private var eventsPushed:Array<String> = [];
	private var totalColumns: Int = 4;

	private function generateSong():Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeed = PlayState.SONG.speed;
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype');
		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
		}

		var songData = SONG;
		Conductor.bpm = songData.bpm;

		curSong = songData.song;

		vocals = new FlxSound();
		opponentVocals = new FlxSound();
		if(songName == 'unfuckable') beatusVocals = new FlxSound();

		try
		{
			if (songData.needsVoices)
			{
				var playerVocals = Paths.voices(songData.song, (boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile);
				vocals.loadEmbedded(playerVocals != null ? playerVocals : Paths.voices(songData.song));
				
				var oppVocals = Paths.voices(songData.song, (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile);
				if(oppVocals != null && oppVocals.length > 0) opponentVocals.loadEmbedded(oppVocals);

				if(songName == 'unfuckable')
				{
					var beatVocals = Paths.voices(songData.song, 'Beatus');
					if(beatVocals != null && beatVocals.length > 0) beatusVocals.loadEmbedded(beatVocals);
				}
			}
		}
		catch (e:Dynamic) {}

		#if FLX_PITCH
		vocals.pitch = playbackRate;
		opponentVocals.pitch = playbackRate;
		if(songName == 'unfuckable') beatusVocals.pitch = playbackRate;
		#end
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(opponentVocals);
		if(songName == 'unfuckable') FlxG.sound.list.add(beatusVocals);

		inst = new FlxSound();
		try
		{
			inst.loadEmbedded(Paths.inst(songData.song));
		}
		catch (e:Dynamic) {}
		FlxG.sound.list.add(inst);

		notes = new FlxTypedGroup<Note>();
		noteGroup.add(notes);

		try
		{
			var eventsChart:SwagSong = Song.getChart('events', songName);
			if(eventsChart != null)
				for (event in eventsChart.events) //Event Notes
					for (i in 0...event[1].length)
						makeEvent(event, i);
		}
		catch(e:Dynamic) {}

		var oldNote:Note = null;
		var sectionsData:Array<SwagSection> = PlayState.SONG.notes;
		var ghostNotesCaught:Int = 0;
		var daBpm:Float = Conductor.bpm;
	
		for (section in sectionsData)
		{
			if (section.changeBPM != null && section.changeBPM && section.bpm != null && daBpm != section.bpm)
				daBpm = section.bpm;

			for (i in 0...section.sectionNotes.length)
			{
				final songNotes: Array<Dynamic> = section.sectionNotes[i];
				var spawnTime: Float = songNotes[0];
				var noteColumn: Int = Std.int(songNotes[1] % totalColumns);
				var holdLength: Float = songNotes[2];
				var noteType: String = !Std.isOfType(songNotes[3], String) ? Note.defaultNoteTypes[songNotes[3]] : songNotes[3];
				if (Math.isNaN(holdLength))
					holdLength = 0.0;

				var gottaHitNote:Bool = (songNotes[1] < totalColumns);

				if (i != 0) {
					// CLEAR ANY POSSIBLE GHOST NOTES
					for (evilNote in unspawnNotes) {
						var matches: Bool = (noteColumn == evilNote.noteData && gottaHitNote == evilNote.mustPress && evilNote.noteType == noteType);
						if (matches && Math.abs(spawnTime - evilNote.strumTime) < flixel.math.FlxMath.EPSILON) {
							if (evilNote.tail.length > 0)
								for (tail in evilNote.tail)
								{
									tail.destroy();
									unspawnNotes.remove(tail);
								}
							evilNote.destroy();
							unspawnNotes.remove(evilNote);
							ghostNotesCaught++;
							//continue;
						}
					}
				}

				var swagNote:Note = new Note(spawnTime, noteColumn, oldNote);
				var isAlt: Bool = section.altAnim && !gottaHitNote;
				swagNote.gfNote = (section.gfSection && gottaHitNote == section.mustHitSection);
				swagNote.animSuffix = isAlt ? "-alt" : "";
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = holdLength;
				swagNote.noteType = noteType;
	
				swagNote.scrollFactor.set();
				unspawnNotes.push(swagNote);

				var curStepCrochet:Float = 60 / daBpm * 1000 / 4.0;
				final roundSus:Int = Math.round(swagNote.sustainLength / curStepCrochet);
				if(roundSus > 0)
				{
					for (susNote in 0...roundSus)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(spawnTime + (curStepCrochet * susNote), noteColumn, oldNote, true);
						sustainNote.animSuffix = swagNote.animSuffix;
						sustainNote.mustPress = swagNote.mustPress;
						sustainNote.gfNote = swagNote.gfNote;
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						swagNote.tail.push(sustainNote);

						sustainNote.correctionOffset = swagNote.height / 2;

						oldNote.scale.y /= playbackRate;
						oldNote.resizeByRatio(curStepCrochet / Conductor.stepCrochet);

						if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2; // general offset
						else if(ClientPrefs.data.middleScroll)
						{
							sustainNote.x += 310;
							if(noteColumn > 1) //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.data.middleScroll)
				{
					swagNote.x += 310;
					if(noteColumn > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if(!noteTypes.contains(swagNote.noteType))
					noteTypes.push(swagNote.noteType);

				oldNote = swagNote;
			}
		}
		trace('["${SONG.song.toUpperCase()}" CHART INFO]: Ghost Notes Cleared: $ghostNotesCaught');
		for (event in songData.events) //Event Notes
			for (i in 0...event[1].length)
				makeEvent(event, i);

		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
	}

	// called only once per different event (Used for precaching)
	function eventPushed(event:EventNote) {
		eventPushedUnique(event);
		if(eventsPushed.contains(event.event)) {
			return;
		}

		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
		eventsPushed.push(event.event);
	}

	// called by every event with the same name
	function eventPushedUnique(event:EventNote) {
		switch(event.event) {
			case "Change Character":
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					case 'mom' | 'second opponent':
						charType = 3;
					case 'bro' | 'third opponent':
						charType = 4;
					default:
						var val1:Int = Std.parseInt(event.value1);
						if(Math.isNaN(val1)) val1 = 0;
						charType = val1;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Play Sound':
				Paths.sound(event.value1); //Precache sound

			case 'Cinematic Bars':
				uiGroup.add(topBar);
				uiGroup.add(bottomBar);
		}
		stagesFunc(function(stage:BaseStage) stage.eventPushedUnique(event));
	}

	function eventEarlyTrigger(event:EventNote):Float {
		var returnedValue:Dynamic = callOnScripts('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], true, [], [0]);
		returnedValue = Std.parseFloat(returnedValue);
		if(!Math.isNaN(returnedValue) && returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function makeEvent(event:Array<Dynamic>, i:Int)
	{
		var subEvent:EventNote = {
			strumTime: event[0] + ClientPrefs.data.noteOffset,
			event: event[1][i][0],
			value1: event[1][i][1],
			value2: event[1][i][2],
			value3: event[1][i][3],
			value4: event[1][i][4],
			value5: event[1][i][5]
		};
		eventNotes.push(subEvent);
		eventPushed(subEvent);
		callOnScripts('onEventPushed', [subEvent.event, subEvent.value1 != null ? subEvent.value1 : '', subEvent.value2 != null ? subEvent.value2 : '', subEvent.strumTime]);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		var strumLineX:Float = ClientPrefs.data.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X;
		var strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.data.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.data.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(strumLineX, strumLineY, i, player);
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else babyArrow.alpha = targetAlpha;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
			{
				if(ClientPrefs.data.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.playerPosition();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				opponentVocals.pause();
				if(songName == 'unfuckable') beatusVocals.pause();
			}

			if(videoCutscene != null) videoCutscene.videoSprite.pause();
			//if(sequence2 != null) sequence2.videoSprite.pause();
			if(sequences != null) sequences.videoSprite.pause();
			if(hypnoBg != null) hypnoBg.videoSprite.pause();

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = false);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = false);
		}

		super.openSubState(SubState);
	}

	public var canResync:Bool = true;
	override function closeSubState()
	{
		super.closeSubState();
		
		stagesFunc(function(stage:BaseStage) stage.closeSubState());
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong && canResync)
			{
				resyncVocals();
			}

			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = true);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = true);
			if(videoCutscene != null) videoCutscene.resume();
			//if(sequence2 != null) sequence2.resume();
			if(sequences != null) sequences.resume();
			if(hypnoBg != null) hypnoBg.resume();

			paused = false;
			callOnScripts('onResume');
			resetRPC(startTimer != null && startTimer.finished);
		}
	}

	override public function onFocus():Void
	{
		if (!paused)
		{
			if (health > 0) resetRPC(Conductor.songPosition > 0.0);
			if (videoCutscene != null) videoCutscene.resume();
			//if (sequence2 != null) sequence2.resume();
			if (sequences != null) sequences.resume();
			if (hypnoBg != null) hypnoBg.resume();
		}
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (!paused)
		{
			#if DISCORD_ALLOWED
			if (health > 0 && autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			#end
			if (videoCutscene != null) videoCutscene.pause();
			//if (sequence2 != null) sequence2.pause();
			if (sequences != null) sequences.pause();
			if (hypnoBg != null) hypnoBg.pause();
		}

		super.onFocusLost();
	}

	// Updating Discord Rich Presence.
	public var autoUpdateRPC:Bool = true; //performance setting for custom RPC things
	function resetRPC(?showTime:Bool = false)
	{
		#if DISCORD_ALLOWED
		if(!autoUpdateRPC) return;

		if (showTime)
			DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLengthDiscord - Conductor.songPosition - ClientPrefs.data.noteOffset);
		else
			DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter());
		#end
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		trace('resynced vocals at ' + Math.floor(Conductor.songPosition));

		FlxG.sound.music.play();
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		if(sequences != null) sequences.videoSprite.bitmap.time = fromFloat(FlxG.sound.music.time);

		var checkVocals = [vocals, opponentVocals];
		if(songName == 'unfuckable') checkVocals = [vocals, opponentVocals, beatusVocals];

		for (voc in checkVocals)
		{
			if (FlxG.sound.music.time < vocals.length)
			{
				voc.time = FlxG.sound.music.time;
				#if FLX_PITCH voc.pitch = playbackRate; #end
				voc.play();
			}
			else voc.pause();
		}
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var freezeCamera:Bool = false;
	var allowDebugKeys:Bool = true;

	var char:Character;

	override public function update(elapsed:Float)
	{
		if(!inCutscene && !paused && !freezeCamera)
			FlxG.camera.followLerp = 0.04 * cameraSpeed * playbackRate;
		else 
			FlxG.camera.followLerp = 0;

		if (!ClientPrefs.data.lowQuality)
		{
			if (fireHalapeno.alpha >= 0.001)
				fireHalapeno.alpha -= 0.01;
		}

		if (fireFlash.alpha >= 0.001)
			fireFlash.alpha -= 0.01;

		wave2Zom.x = iconP1.x;

		callOnScripts('onUpdate', [elapsed]);

		super.update(elapsed);

		setOnScripts('curDecStep', curDecStep);
		setOnScripts('curDecBeat', curDecBeat);

		var mult:Float = FlxMath.lerp(smoothHealth, health, 0.15 * playbackRate);
		smoothHealth = mult;

		if(botplayTxt != null && botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnScripts('onPause', null, true);
			if(ret != LuaUtils.Function_Stop) {
				openPauseMenu();
			}
		}

		if(!endingSong && !inCutscene && allowDebugKeys)
		{
			if (controls.justPressed('debug_1'))
				openChartEditor();
		}

		if (healthBar.bounds.max != null && health > healthBar.bounds.max)
			health = healthBar.bounds.max;

		updateIconsScale(elapsed);
		updateIconsPosition();

		if (startedCountdown && !paused)
		{
			Conductor.songPosition += elapsed * 1000 * playbackRate;
			if (Conductor.songPosition >= Conductor.offset)
			{
				Conductor.songPosition = FlxMath.lerp(FlxG.sound.music.time + Conductor.offset, Conductor.songPosition, Math.exp(-elapsed * 5));
				var timeDiff:Float = Math.abs((FlxG.sound.music.time + Conductor.offset) - Conductor.songPosition);
				if (timeDiff > 1000 * playbackRate)
					Conductor.songPosition = Conductor.songPosition + 1000 * FlxMath.signOf(timeDiff);
			}
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= Conductor.offset)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5 + Conductor.offset;
		}
		else if (!paused && updateTime)
		{
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
			songPercent = (curTime / songLength);

			var songCalc:Float = (songLength - curTime);
			if(ClientPrefs.data.timeBarType == 'Time Elapsed') songCalc = curTime;

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			if(ClientPrefs.data.timeBarType != 'Song Name')
				timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
		}

		if (cameraZoomRate > 0.0)
		{
			cameraBopMultiplier = FlxMath.lerp(1.0, cameraBopMultiplier, 0.95 * playbackRate); // Lerp bop multiplier back to 1.0x
			var zoomPlusBop:Float = currentCameraZoom * cameraBopMultiplier; // Apply camera bop multiplier.
			FlxG.camera.zoom = zoomPlusBop; // Actually apply the zoom to the camera.
		
			camHUD.zoom = FlxMath.lerp(defaultHUDCameraZoom, camHUD.zoom, 0.95 * playbackRate);
			camHudBehind.zoom = FlxMath.lerp(1, camHudBehind.zoom, 0.95 * playbackRate);
		}

		if (SONG.notes[curSection] != null)
		{
			if(SONG.notes[curSection].mustHitSection && boyfriend.getAnimationName() == "idle")
			{
				FlxG.camera.targetOffset.x = 0;
				FlxG.camera.targetOffset.y = 0;
			}

			if(dad.visible == true)
				char = dad;
			else if (bro.visible == true)
				char = bro;
			else if (mom.visible == true)
				char = mom;
			else
				char = boyfriend;

			if(!SONG.notes[curSection].mustHitSection && (char.getAnimationName() == "idle" || char.getAnimationName() == "danceLeft" || char.getAnimationName() == "danceRight"))
			{
				FlxG.camera.targetOffset.x = 0;
                FlxG.camera.targetOffset.y = 0;
			}
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.data.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime * playbackRate;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;

				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote, dunceNote.strumTime]);
				callOnHScript('onSpawnNote', [dunceNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(!cpuControlled)
					keysCheck();
				else
					playerDance();

				if(notes.length > 0)
				{
					if(startedCountdown)
					{
						var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
						notes.forEachAlive(function(daNote:Note)
						{
							var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
							if(!daNote.mustPress) strumGroup = opponentStrums;

							var strum:StrumNote = strumGroup.members[daNote.noteData];
							daNote.followStrumNote(strum, fakeCrochet, songSpeed / playbackRate);

							if(daNote.mustPress)
							{
								if(cpuControlled && !daNote.blockHit && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition))
									goodNoteHit(daNote);
							}
							else if (daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
								opponentNoteHit(daNote);

							if(daNote.isSustainNote && strum.sustainReduce) daNote.clipToStrumNote(strum);

							// Kill extremely late notes and cause misses
							if (Conductor.songPosition - daNote.strumTime > noteKillOffset)
							{
								if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
									noteMiss(daNote);

								daNote.active = daNote.visible = false;
								invalidateNote(daNote);
							}
						});
					}
					else
					{
						notes.forEachAlive(function(daNote:Note)
						{
							daNote.canBeHit = false;
							daNote.wasGoodHit = false;
						});
					}
				}
			}
			checkEventNote();
		}

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		for (holdNote in notes.members)
		{
			if (holdNote == null || !holdNote.alive || !holdNote.mustPress) continue;

			if (holdNote.noteWasHit && !holdNote.missed && holdNote.isSustainNote)
			{
				health += 0.15 * elapsed;

				if(!cpuControlled)
				{
					songScore += Std.int(250 * elapsed);
					updateScore(false);
				}
				else
				{
					var tempScore:String;
					tempScore = 'Score: BOT'
					+ '\nAccuracy: BOT'
					+ '\nMisses: BOT';

					scoreTxt.text = tempScore;
				}
			}
		}

		setOnScripts('botPlay', cpuControlled);
		callOnScripts('onUpdatePost', [elapsed]);

		if(generatedMusic && !inCutscene && ClientPrefs.data.laneUnderlay != 0)
		{
			laneP0.x = playerStrums.members[0].x;
			laneP1.x = playerStrums.members[1].x;
			laneP2.x = playerStrums.members[2].x;
			laneP3.x = playerStrums.members[3].x;
	
			laneE0.x = opponentStrums.members[0].x;
			laneE1.x = opponentStrums.members[1].x;
			laneE2.x = opponentStrums.members[2].x;
			laneE3.x = opponentStrums.members[3].x;
	
			laneP0.alpha = (
				playerStrums.members[0].alpha == 0 ?
					FlxMath.lerp(laneP0.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneP0.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
			laneP1.alpha = (
				playerStrums.members[1].alpha == 0 ?
					FlxMath.lerp(laneP1.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneP1.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
			laneP2.alpha = (
				playerStrums.members[2].alpha == 0 ?
					FlxMath.lerp(laneP2.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneP2.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
			laneP3.alpha = (
				playerStrums.members[3].alpha == 0 ?
					FlxMath.lerp(laneP3.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneP3.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
	
			laneE0.alpha = (
				opponentStrums.members[0].alpha == 0 ?
					FlxMath.lerp(laneE0.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneE0.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
			laneE1.alpha = (
				opponentStrums.members[1].alpha == 0 ?
					FlxMath.lerp(laneE1.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneE1.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
			laneE2.alpha = (
				opponentStrums.members[2].alpha == 0 ?
					FlxMath.lerp(laneE2.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneE2.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
			laneE3.alpha = (
				opponentStrums.members[3].alpha == 0 ?
					FlxMath.lerp(laneE3.alpha, 0, FlxMath.bound(elapsed * 5, 0, 1))
					:
					FlxMath.lerp(laneE3.alpha, ClientPrefs.data.laneUnderlay, FlxMath.bound(elapsed * 5, 0, 1))
			);
		}

		if(FlxG.overlap(jacksonDrain, iconP1))
		{
			health -= elapsed * 2;

			FlxTween.angle(iconP1, FlxG.random.float(-20, 20), 0, ((1 / (Conductor.bpm / 60))), {ease: FlxEase.backOut});
			FlxTween.color(iconP1, (1 / (Conductor.bpm / 60)), 0xFF3B3B3B, FlxColor.WHITE, {ease: FlxEase.circOut});
		}

		if(ghostToggle)
		{
			if (bro.alpha >= 0) bro.alpha -= 0.01 * (elapsed/(1/60));
			if (mom.alpha >= 0) mom.alpha -= 0.01 * (elapsed/(1/60));
		}

		if(SONG.song == 'ezqsvf')
		{
			if (Conductor.songPosition > finishLength)
				reloadSong();
		}
	}

	// Health icon updaters
	public dynamic function updateIconsScale(elapsed:Float)
	{
		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-elapsed * 9 * playbackRate));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, Math.exp(-elapsed * 9 * playbackRate));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var multGay:Float = FlxMath.lerp(1, iconP2.scale.x, Math.exp(-elapsed * 9 * playbackRate));
		iconPEP.scale.set(multGay, multGay);
		iconPEP.updateHitbox();

		iconPOLE.scale.set(multGay, multGay);
		iconPOLE.updateHitbox();

		iconJACK.scale.set(multGay, multGay);
		iconJACK.updateHitbox();
	}

	public dynamic function updateIconsPosition()
	{
		var iconOffset:Int = 26;
		iconP1.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		iconPEP.setPosition(iconP2.x + ycbuIconPos1.x, iconP2.y + ycbuIconPos1.y);
		iconPOLE.setPosition(iconP2.x + ycbuIconPos2.x, iconP2.y + ycbuIconPos2.y);
		iconJACK.setPosition(iconP2.x + ycbuIconPos3.x, iconP2.y + ycbuIconPos3.y);

		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : (healthBar.percent > 80) ? 2 : 0;
		iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : (healthBar.percent < 20) ? 2 : 0;

		iconPEP.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : (healthBar.percent < 20) ? 2 : 0;
		iconJACK.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : (healthBar.percent < 20) ? 2 : 0;
		iconPOLE.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : (healthBar.percent < 20) ? 2 : 0;
	}

	var iconsAnimations:Bool = true;
	function set_health(value:Float):Float // You can alter how icon animations work here
	{
		value = FlxMath.roundDecimal(value, 5); //Fix Float imprecision
		if(!iconsAnimations || healthBar == null || !healthBar.enabled || healthBar.valueFunction == null)
		{
			health = value;
			return health;
		}

		// update health bar
		health = value;
		var newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);

		return health;
	}

	function openPauseMenu()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
			if(songName == 'unfuckable') beatusVocals.pause();
		}
		if(!cpuControlled)
		{
			for (note in playerStrums)
				if(note.animation.curAnim != null && note.animation.curAnim.name != 'static')
				{
					note.playAnim('static');
					note.resetAnim = 0;
				}
		}

		if(chartingMode)
			openSubState(new PauseSubStateOld());
		else
			openSubState(new PauseSubState());

		#if DISCORD_ALLOWED
		if(autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		canResync = false;
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if(vocals != null)
			vocals.pause();
		if(opponentVocals != null)
			opponentVocals.pause();

		if(songName == 'unfuckable')
		{
			if(beatusVocals != null)
				beatusVocals.pause();
		}

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("он сосет хуй, мешайте", null, null, true);
		DiscordClient.resetClientID();
		#end

		if(SONG.song != "ezqsvf")
		{
            PlayState.storyPlaylist = ['ezqsvf'];
            PlayState.isStoryMode = false;
    
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

			if(!ClientPrefs.data.optimize) LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
    
            FlxG.sound.music.stop();
            return;
		}
		else
		{
			MusicBeatState.switchState(new LohState());
		}
		/*chartingMode = true;
		MusicBeatState.switchState(new ChartingState());*/
	}

	function openCharacterEditor()
	{
		canResync = false;
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if(vocals != null)
			vocals.pause();
		if(opponentVocals != null)
			opponentVocals.pause();

		if(songName == 'unfuckable')
		{
			if(beatusVocals != null)
				beatusVocals.pause();
		}

		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
		MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	public var gameOverTimer:FlxTimer;
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead && gameOverTimer == null)
		{
			var ret:Dynamic = callOnScripts('onGameOver', null, true);
			if(ret != LuaUtils.Function_Stop)
			{
				FlxG.animationTimeScale = 1;
				boyfriend.stunned = true;
				deathCounter++;

				if(respawned)
				{
					respawnPoint = 0;
					respawned = false;
				}

				changedDifficulty = false;

				camGame.bgColor = 0xFF000000;

				paused = true;
				canResync = false;
				canPause = false;

				if(videoCutscene != null)
				{
					videoCutscene.destroy();
					videoCutscene = null;
				}

				/*if(sequence2 != null)
				{
					sequence2.destroy();
					sequence2 = null;
				}*/

				if(sequences != null)
				{
					sequences.destroy();
					sequences = null;
				}

				if(hypnoBg != null)
				{
					hypnoBg.destroy();
					hypnoBg = null;
				}

				persistentUpdate = false;
				persistentDraw = false;
				FlxTimer.globalManager.clear();
				FlxTween.globalManager.clear();
				FlxG.camera.setFilters([]);

				if(GameOverSubstate.deathDelay > 0)
				{
					gameOverTimer = new FlxTimer().start(GameOverSubstate.deathDelay, function(_)
					{
						vocals.stop();
						opponentVocals.stop();
						if(songName == 'unfuckable') beatusVocals.stop();
						FlxG.sound.music.stop();
						openSubState(new GameOverSubstate(boyfriend));
						gameOverTimer = null;
					});
				}
				else
				{
					vocals.stop();
					opponentVocals.stop();
					if(songName == 'unfuckable') beatusVocals.stop();
					FlxG.sound.music.stop();
					openSubState(new GameOverSubstate(boyfriend));
				}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if DISCORD_ALLOWED
				// Game Over doesn't get his its variable because it's only used here
				if(autoUpdateRPC) DiscordClient.changePresence("Game Over - " + detailsText, SONG.song, iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			var value3:String = '';
			if(eventNotes[0].value3 != null)
				value3 = eventNotes[0].value3;

			var value4:String = '';
			if(eventNotes[0].value4 != null)
				value4 = eventNotes[0].value4;

			var value5:String = '';
			if(eventNotes[0].value5 != null)
				value5 = eventNotes[0].value5;

			triggerEvent(eventNotes[0].event, value1, value2, value3, value4, value5, leStrumTime);
			eventNotes.shift();
		}
	}

	public function triggerEvent(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, strumTime:Float) {
		var flValue1:Null<Float> = Std.parseFloat(value1);
		var flValue2:Null<Float> = Std.parseFloat(value2);
		var flValue3:Null<Float> = Std.parseFloat(value3);
		var flValue4:Null<Float> = Std.parseFloat(value4);
		var flValue5:Null<Float> = Std.parseFloat(value5);
		if(Math.isNaN(flValue1)) flValue1 = null;
		if(Math.isNaN(flValue2)) flValue2 = null;
		if(Math.isNaN(flValue3)) flValue3 = null;
		if(Math.isNaN(flValue4)) flValue4 = null;
		if(Math.isNaN(flValue5)) flValue5 = null;

		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				if(flValue2 == null || flValue2 <= 0) flValue2 = 0.6;

				if(value != 0) {
					if(gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = flValue2;
				}

			case 'Set GF Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 1;
				gfSpeed = Math.round(flValue1);

			case 'Set DAD Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 2;
				dad.danceEveryNumBeats = Math.round(flValue1);

			case 'Set BF Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 2;
				boyfriend.danceEveryNumBeats = Math.round(flValue1);

			case 'Set MOM Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 2;
				mom.danceEveryNumBeats = Math.round(flValue1);

			case 'Set BRO Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 2;
				mom.danceEveryNumBeats = Math.round(flValue1);

			case 'Add Camera Zoom':
				if(ClientPrefs.data.camZooms && FlxG.camera.zoom < 1.7) {
					if(flValue1 == null) flValue1 = 0.015;
					if(flValue2 == null) flValue2 = 0.03;

					cameraBopMultiplier += flValue1;
					camHUD.zoom += flValue2;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					case 'bro' | 'third opponent':
						char = bro;
					case 'mom' | 'second opponent':
						char = mom;
					default:
						if(flValue2 == null) flValue2 = 0;
						switch(Math.round(flValue2)) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Play Uninterruptable Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					case 'mom' | 'mother':
						char = mom;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.uninterruptableAnim = true;
					char.specialAnim = true;
				}

			case "Focus Camera":
				var coordsStr:Array<String> = value4.split(",");
					
				var char:String = value1 ?? "dad";
		
				var duration:Float = flValue2;
				if (flValue2 == null)
					duration = 4.0;
		
				var ease:String = value3 ?? "CLASSIC";
		
				var targetX:Float = Std.parseFloat(coordsStr[0]);
				var targetY:Float = Std.parseFloat(coordsStr[1]);
		
				if (Math.isNaN(targetX))
					targetX = 0;
				if (Math.isNaN(targetY))
					targetY = 0;
		
				switch (char.toLowerCase())
				{
					case "origin":
						trace("Chose origin");
					case "bf":
						targetX += boyfriend.getMidpoint().x - boyfriend.cameraPosition[0] + boyfriendCameraOffset[0] - 100;
						targetY += boyfriend.getMidpoint().y + boyfriend.cameraPosition[1] + boyfriendCameraOffset[1] - 100;
					case "gf":
						targetX += gf.getMidpoint().x + gf.cameraPosition[0] + girlfriendCameraOffset[0];
						targetY += gf.getMidpoint().y + gf.cameraPosition[1] + girlfriendCameraOffset[1];
					case "mom":
						targetX += mom.getMidpoint().x + mom.cameraPosition[0] + opponentCameraOffset[0] + 150;
						targetY += mom.getMidpoint().y + mom.cameraPosition[1] + opponentCameraOffset[1] - 100;
					case "bro":
						targetX += bro.getMidpoint().x + bro.cameraPosition[0] + opponentCameraOffset[0] + 150;
						targetY += bro.getMidpoint().y + bro.cameraPosition[1] + opponentCameraOffset[1] - 100;
					default:
						targetX += dad.getMidpoint().x + dad.cameraPosition[0] + opponentCameraOffset[0] + 150;
						targetY += dad.getMidpoint().y + dad.cameraPosition[1] + opponentCameraOffset[1] - 100;
						
				}
		
				switch (ease)
				{
					case 'CLASSIC': // Old-school. No ease. Just set follow point.
						resetCamera(false, false, false);
						cancelCameraFollowTween();
						cameraFollowPoint.setPosition(targetX, targetY);
					case 'INSTANT': // Instant ease. Duration is automatically 0.
						tweenCameraToPosition(targetX, targetY, 0);
					default:
						var durSeconds:Float = Conductor.stepCrochet * duration / 1000;
						tweenCameraToPosition(targetX, targetY, durSeconds, LuaUtils.getTweenEaseByString(ease));
				}

			case 'Update Strum':
				for (i in 0...playerStrums.length) {
					setOnScripts('defaultPlayerStrumX' + i, playerStrums.members[i].x);
					setOnScripts('defaultPlayerStrumY' + i, playerStrums.members[i].y);
				}
				for (i in 0...opponentStrums.length) {
					setOnScripts('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
					setOnScripts('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
					//if(ClientPrefs.data.middleScroll) opponentStrums.members[i].visible = false;
				}

			case "Set Camera Bop":
				var rate:Int = Std.parseInt(value1);
				var intensity:Float = Std.parseFloat(value2);

				cameraBopIntensity = 0.015 * intensity + 1.0;
				hudCameraZoomIntensity = 0.015 * intensity * 2.0;

				cameraZoomRate = rate;

			case "Zoom Camera":	
				var zoom:Float = flValue2 ?? 1.0;
				var duration:Float = flValue3 ?? 4.0;
					
				var mode:String = value4 ?? "direct";
				var isDirectMode:Bool = mode == "direct";
		
				if (value1 == "")
					value1 = "linear";
		
				switch(value1)
				{
					case "INSTANT":
						tweenCameraZoom(zoom, 0, isDirectMode);
					default:
						var durSeconds:Float = Conductor.stepCrochet * duration / 1000;
						tweenCameraZoom(zoom, durSeconds, isDirectMode, LuaUtils.getTweenEaseByString(value1));
				}
			case "Camera Angle":
				var angleChange:Float = flValue2 ?? 0;
				var duration:Float = flValue3 ?? 4.0;
		
				if (value1 == "")
					value1 = "linear";

				var durSeconds:Float = Conductor.stepCrochet * duration / 1000;

				switch(value4)
				{
					case 'camgame' | 'camGame':
						FlxTween.cancelTweensOf(camGame.angle);
						FlxTween.tween(camGame, {angle: angleChange}, durSeconds / playbackRate, {ease: LuaUtils.getTweenEaseByString(value1)});
					case 'camhud' | 'camHUD' | 'hud':
						FlxTween.cancelTweensOf(camHUD.angle);
						FlxTween.tween(camHUD, {angle: angleChange}, durSeconds / playbackRate, {ease: LuaUtils.getTweenEaseByString(value1)});
					case 'camhudbehind' | 'hudbehind' | 'video':
						FlxTween.cancelTweensOf(camHudBehind.angle);
						FlxTween.tween(camHudBehind, {angle: angleChange}, durSeconds / playbackRate, {ease: LuaUtils.getTweenEaseByString(value1)});
					case 'camOther' | 'camother' | 'other':
						FlxTween.cancelTweensOf(camOther.angle);
						FlxTween.tween(camOther, {angle: angleChange}, durSeconds / playbackRate, {ease: LuaUtils.getTweenEaseByString(value1)});
				}

			case 'Change Note Camera Move Offset':
				nOffset = Std.parseFloat(value1);

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					case 'mom' | 'second opponent':
						char = mom;
					case 'bro' | 'third opponent':
						char = bro;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Shake Beat':
				if(!ClientPrefs.data.flashing) return;

				shakeBeat = !shakeBeat;

			case 'Screen Shake':
				if(!ClientPrefs.data.flashing) return;
				
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					case 'mom' | 'second opponent':
						charType = 3;
					case 'bro' | 'third opponent':
						charType = 4;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnScripts('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnScripts('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnScripts('gfName', gf.curCharacter);
						}

					case 3:
						if(mom.curCharacter != value2) {
							if(mom.curCharacter != value2) {
								if(!momMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}
	
								var lastAlpha:Float = mom.alpha;
								mom.alpha = 0.00001;
								mom = momMap.get(value2);
								mom.alpha = lastAlpha;
								//iconP2.changeIcon(mom.healthIcon);
							}
						}
					case 4:
						if(bro.curCharacter != value2) {
							if(bro.curCharacter != value2) {
								if(!broMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}
	
								var lastAlpha:Float = bro.alpha;
								bro.alpha = 0.00001;
								bro = broMap.get(value2);
								bro.alpha = lastAlpha;
								//iconP2.changeIcon(mom.healthIcon);
							}
						}
				}

			case 'Dad Icon Bye':
				FlxTween.cancelTweensOf(iconP2);
				FlxTween.tween(iconP2, {alpha: 0}, 3 / playbackRate);

			case 'Wave':
				final antialias:Bool = (ClientPrefs.data.antialiasing);
				countdownGo = createWaveSprite(value1.toLowerCase().trim(), antialias);

			case 'Faking Icons':
				FlxTween.tween(iconPEP, {alpha: 1}, 1 / playbackRate, {ease: FlxEase.quadOut});
				reloadHealthBarColors('nothing');

			case 'Swap Icon':
				FlxTween.cancelTweensOf(ycbuIconPos1);
				FlxTween.cancelTweensOf(ycbuIconPos3);
				FlxTween.cancelTweensOf(ycbuIconPos2);
				switch(value1){
					case 'pole':
						//show duck hunt
						FlxTween.tween(iconPOLE, {alpha: 1}, 0.2 / playbackRate, {ease: FlxEase.quadOut});
					case 'jackson':
						//show bowser
						FlxTween.tween(iconJACK, {alpha: 1}, 0.2 / playbackRate, {ease: FlxEase.quadOut});
					case 'pep':
						var iconPos3x:Float = ycbuIconPos3.x;
						var iconPos3y:Float = ycbuIconPos3.y;

						FlxTween.cancelTweensOf(ycbuIconPos1);
						FlxTween.cancelTweensOf(ycbuIconPos3);
						FlxTween.cancelTweensOf(ycbuIconPos2);

						FlxTween.tween(ycbuIconPos1, {x: ycbuIconPos2.x, y: ycbuIconPos2.y}, 0.2 / playbackRate, {ease: FlxEase.quadOut});
						FlxTween.tween(ycbuIconPos3, {x: ycbuIconPos1.x, y: ycbuIconPos1.y}, 0.2 / playbackRate, {ease: FlxEase.quadOut});
						FlxTween.tween(ycbuIconPos2, {x: iconPos3x, y: iconPos3y}, 0.2 / playbackRate, {ease: FlxEase.quadOut});
				}

				if (value1 != 'pep'){
					var iconPos3x:Float = ycbuIconPos3.x;
					var iconPos3y:Float = ycbuIconPos3.y;

					FlxTween.cancelTweensOf(ycbuIconPos1);
					FlxTween.cancelTweensOf(ycbuIconPos3);
					FlxTween.cancelTweensOf(ycbuIconPos2);

					FlxTween.tween(ycbuIconPos3, {x: ycbuIconPos2.x, y: ycbuIconPos2.y}, 0.2 / playbackRate, {ease: FlxEase.quadOut});
					FlxTween.tween(ycbuIconPos2, {x: ycbuIconPos1.x, y: ycbuIconPos1.y}, 0.2 / playbackRate, {ease: FlxEase.quadOut});
					FlxTween.tween(ycbuIconPos1, {x: iconPos3x, y: iconPos3y}, 0.2 / playbackRate, {ease: FlxEase.quadOut});
				}

				var whoTo:String = value1; 

			case 'Change Icon':
				FlxTween.cancelTweensOf(iconP2);

				FlxTween.tween(iconP2, {alpha: 0}, 1 / playbackRate, {onComplete:
					function (twn:FlxTween)
					{
						var iconToSwitch:HealthIcon = 
						switch(value1.toLowerCase().trim())
						{
							case 'dad' | 'opponent' | 'p2':
								iconP2;
							default:
								iconP1;
						}
						iconToSwitch.changeIcon(value2);

						var who:String = value3;

						switch(who)
						{
							case 'pole': reloadHealthBarColors('pole');
							case 'jackson': reloadHealthBarColors('jackson');
							default: reloadHealthBarColors();
						}
						FlxTween.tween(iconP2, {alpha: 1}, 1 / playbackRate);
					}
				});

			case 'Ghost Behind':
				ghostToggle = !ghostToggle;

				if(!ghostToggle)
				{
					mom.color = 0xFFFFFFFF;
					bro.color = 0xFFFFFFFF;
					if(value1 == '0')
					{
						mom.alpha = 0;
						bro.alpha = 0;
					}
					else
					{
						mom.alpha = 1;
						bro.alpha = 1;
					}
				}
				else
				{
					mom.color = 0xFF000000;
					bro.color = 0xFF000000;
					left = true;
				}

			case 'Change Scroll Speed':
				if (songSpeedType != "constant")
				{
					if(flValue1 == null) flValue1 = 1;
					if(flValue2 == null) flValue2 = 0;

					var ease = LuaUtils.getTweenEaseByString(value3);

					var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
					if(flValue2 <= 0)
						songSpeed = newValue;
					else
						songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, flValue2 / playbackRate, {ease: ease, onComplete:
							function (twn:FlxTween)
							{
								songSpeedTween = null;
							}
						});
				}

			case 'Flash Camera':
				var color:FlxColor = 0xFFFFFFFF;
	
				if (value1 == null || value1 == '')
					color = 0xFFFFFFFF;

				color = Std.parseInt(value1);

				if (flValue2 == null) flValue2 = 1;

				if(!ClientPrefs.data.flashing && value1 != '0xFF000000') return;
	
				switch(value3.toLowerCase().trim()) {
					case 'camhud' | 'HUD' | 'hud':
						camHUD.flash(color, flValue2, null, true);
					case 'camhudbehind' | 'hudbehind' | 'video':
						camHudBehind.flash(color, flValue2, null, true);
					case 'camother' | 'camOther' | 'other':
						camOther.flash(color, flValue2, null, true);
					default:
						FlxG.camera.flash(color, flValue2, null, true);
				}

			case 'Fade Camera':
				if(!ClientPrefs.data.flashing) return;

				var color:FlxColor = 0xFFFFFFFF;
	
				if (value1 == null || value1 == '')
					color = 0xFFFFFFFF;

				color = Std.parseInt(value1);

				if (flValue2 == null) flValue2 = 1;
	
				switch(value3.toLowerCase().trim()) {
					case 'camhud' | 'hud':
						camHUD.fade(color, flValue2, directionFade, null, true);
					case 'camother' | 'other':
						camOther.fade(color, flValue2, directionFade, null, true);
					case 'camhudbehind' | 'hudbehind' | 'video':
						camHudBehind.fade(color, flValue2, directionFade, null, true);
					default:
						FlxG.camera.fade(color, flValue2, directionFade, null, true);
				}

				directionFade = !directionFade;

			case 'Set Health':
				health = flValue1;

			case 'Add Health':
				health += flValue1;

			case 'Set Health Tween':
				var ease = LuaUtils.getTweenEaseByString(value3);
				FlxTween.tween(this, {health: flValue1}, flValue2 / playbackRate, {ease: ease});

			case 'Add Health Tween':
				var ease = LuaUtils.getTweenEaseByString(value3);
				var newhealth:Float = health + flValue1;

				FlxTween.tween(this, {health: newhealth}, flValue2 / playbackRate, {ease: ease});

			case 'Remove Health Limit':
				var newhealth:Float = (health - flValue1);

				if (newhealth < 0.2)
					health = 0.2;
				else
					health -= flValue1;

			case 'Singing Shakes':
				if (!ClientPrefs.data.flashing) return;
				
				var charType:Int = 0;
				switch(value2.toLowerCase().trim())
				{
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType))
							charType = 0;
				}
				switch (value1.toLowerCase().trim())
				{
					case 'on' | 'true':
						singingShakeArray[charType] = true;
					case 'off' | 'false':
						singingShakeArray[charType] = false;
				}

			case 'Opponent Drain':
				switch (value1.toLowerCase().trim())
				{
					case 'on' | 'true':
						opponentHealthDrain = true;
					case 'off' | 'false':
						opponentHealthDrain = false;
				}

				var drain:Float = Std.parseFloat(value2);
				if (Math.isNaN(drain) || value2 == null)
					drain = 0.030;
				
				opponentHealthDrainAmount = drain;

			case 'Beat Drain':
				switch (value1.toLowerCase().trim())
				{
					case 'on' | 'true':
						goHealthDamageBeat = true;
					case 'off' | 'false':
						goHealthDamageBeat = false;
				}

				var drain:Float = Std.parseFloat(value2);
				if (Math.isNaN(drain) || value2 == null)
					drain = 0.030;

				if(flValue3 == null || flValue3 < 1) flValue3 = 8;
				beatHealthStep = Math.round(flValue3);
				
				beatHealthDrain = drain;

			case 'Set Char Position':
				var charType:Int = 0;

				var split:Array<String> = value2.split(',');
				var xMove:Float = Std.parseFloat(split[0]);
				var yMove:Float = Std.parseFloat(split[1]);

				switch (value1)
				{
					case 'dad' | 'Dad' | 'DAD':
						charType = 1;
					case 'mom' | 'Mom' | 'MOM':
						charType = 3;
					case 'bro' | 'Bro' | 'BRO':
						charType = 4;
					case 'gf' | 'GF' | 'girlfriend' | 'Girlfriend':
						charType = 2;
					default:
						charType = 0;
				}

				switch (charType)
				{
					case 1:
						if(Math.isNaN(xMove)) dadGroup.x = DAD_X;
						else dadGroup.x = xMove;

						if(Math.isNaN(yMove)) dadGroup.y = DAD_Y;
						else dadGroup.y = yMove;

					case 2:
						if(Math.isNaN(xMove)) gfGroup.x = GF_X;
						else gfGroup.x = xMove;
	
						if(Math.isNaN(yMove)) gfGroup.y = GF_Y;
						else gfGroup.y = yMove;

					case 3:
						if(Math.isNaN(xMove)) momGroup.x = MOM_X;
						else momGroup.x = xMove;
	
						if(Math.isNaN(yMove)) momGroup.y = MOM_Y;
						else momGroup.y = yMove;

					case 4:
						if(Math.isNaN(xMove)) broGroup.x = BRO_X;
						else broGroup.x = xMove;
	
						if(Math.isNaN(yMove)) broGroup.y = BRO_Y;
						else broGroup.y = yMove;

					default:
						if(Math.isNaN(xMove)) boyfriendGroup.x = BF_X;
						else boyfriendGroup.x = xMove;

						if(Math.isNaN(yMove)) boyfriendGroup.y = BF_Y;
						else boyfriendGroup.y = yMove;
				}

			case 'Set Char Position Tween':
				var charType:Int = 0;

				var split:Array<String> = value2.split(',');
				var xMove:Float = Std.parseFloat(split[0]);
				var yMove:Float = Std.parseFloat(split[1]);

				var ease = LuaUtils.getTweenEaseByString(value4);

				if (flValue3 == null)
					flValue3 = 1;

				switch (value1)
				{
					case 'dad' | 'Dad' | 'DAD':
						charType = 1;
					case 'mom' | 'Mom' | 'MOM':
						charType = 3;
					case 'bro' | 'Bro' | 'BRO':
						charType = 4;
					case 'gf' | 'GF' | 'girlfriend' | 'Girlfriend':
						charType = 2;
					default:
						charType = 0;
				}

				switch (charType)
				{
					case 1:
						if(Math.isNaN(xMove)) xMove = DAD_X;
						if(Math.isNaN(yMove)) yMove = DAD_Y;

						FlxTween.cancelTweensOf(dadGroup);
						FlxTween.tween(dadGroup, {x: xMove, y: yMove}, flValue3 / playbackRate, {ease: ease});

					case 2:
						if(Math.isNaN(xMove)) xMove = GF_X;
						if(Math.isNaN(yMove)) yMove = GF_Y;

						FlxTween.cancelTweensOf(gfGroup);
						FlxTween.tween(gfGroup, {x: xMove, y: yMove}, flValue3 / playbackRate, {ease: ease});

					case 3:
						if(Math.isNaN(xMove)) xMove = MOM_X;
						if(Math.isNaN(yMove)) yMove = MOM_Y;

						FlxTween.cancelTweensOf(momGroup);
						FlxTween.tween(momGroup, {x: xMove, y: yMove}, flValue3 / playbackRate, {ease: ease});

					case 4:
						if(Math.isNaN(xMove)) xMove = BRO_X;
						if(Math.isNaN(yMove)) yMove = BRO_Y;

						FlxTween.cancelTweensOf(broGroup);
						FlxTween.tween(broGroup, {x: xMove, y: yMove}, flValue3 / playbackRate, {ease: ease});

					default:
						if(Math.isNaN(xMove)) xMove = BF_X;
						if(Math.isNaN(yMove)) yMove = BF_Y;

						FlxTween.cancelTweensOf(boyfriendGroup);
						FlxTween.tween(boyfriendGroup, {x: xMove, y: yMove}, flValue3 / playbackRate, {ease: ease});
				}

			case 'Set Char Color':
				var char:Character = boyfriend;
				var val2:Int = Std.parseInt(value2);

				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'dad':
						char = dad;
					case 'mom':
						char = mom;
					case 'bro':
						char = bro;
					default:
						char = boyfriend;
				}

				if (Math.isNaN(val2))
					val2 = 0xFFFFFFFF;
				
				char.color = val2;

			case 'Set Char Color Tween':
				var char:Character = boyfriend;

				if (flValue3 == null)
					flValue3 = 1;

				var ease = LuaUtils.getTweenEaseByString(value4);
				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'dad':
						char = dad;
					case 'mom':
						char = mom;
					case 'bro':
						char = bro;
					default:
						char = boyfriend;
				}

				var curColor:FlxColor = char.color;
				curColor.alphaFloat = char.alpha;
				
				FlxTween.color(char, flValue3 / playbackRate, curColor, CoolUtil.colorFromString(value2), {ease: ease});

			case 'Set Char Color Transform':
				var char:Character = boyfriend;

				var split:Array<String> = value2.split(',');
				var splitAlpha:Array<String> = value3.split(',');
				var redOff:Int = 0;
				var greenOff:Int = 0;
				var blueOff:Int = 0;
				var alphaOff:Int = 0;
				var redMult:Int = 0;
				var greenMult:Int = 0;
				var blueMult:Int = 0;
				var alphaMult:Int = 0;
				if(split[0] != null) redOff = Std.parseInt(split[0].trim());
				if(split[1] != null) greenOff = Std.parseInt(split[1].trim());
				if(split[2] != null) blueOff = Std.parseInt(split[2].trim());
				if(split[3] != null) alphaOff = Std.parseInt(split[3].trim());
				if(splitAlpha[0] != null) redMult = Std.parseInt(splitAlpha[0].trim());
				if(splitAlpha[1] != null) greenMult = Std.parseInt(splitAlpha[1].trim());
				if(splitAlpha[2] != null) blueMult = Std.parseInt(splitAlpha[2].trim());
				if(splitAlpha[3] != null) alphaMult = Std.parseInt(splitAlpha[3].trim());

				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'dad':
						char = dad;
					case 'mom':
						char = mom;
					case 'bro':
						char = bro;
					default:
						char = boyfriend;
				}
				char.colorTransform.redOffset = redOff;
				char.colorTransform.greenOffset = greenOff;
				char.colorTransform.blueOffset = blueOff;
				char.colorTransform.alphaOffset = alphaOff;

				char.colorTransform.redMultiplier = redMult;
				char.colorTransform.greenMultiplier = greenMult;
				char.colorTransform.blueMultiplier = blueMult;
				char.colorTransform.alphaMultiplier = alphaMult;

			case 'Set Char Color Transform Tween':
				var char:Character = boyfriend;

				var split:Array<String> = value2.split(',');
				var splitAlpha:Array<String> = value3.split(',');
				var redOff:Int = 0;
				var greenOff:Int = 0;
				var blueOff:Int = 0;
				var alphaOff:Int = 0;
				var redMult:Int = 0;
				var greenMult:Int = 0;
				var blueMult:Int = 0;
				var alphaMult:Int = 0;
				if(split[0] != null) redOff = Std.parseInt(split[0].trim());
				if(split[1] != null) greenOff = Std.parseInt(split[1].trim());
				if(split[2] != null) blueOff = Std.parseInt(split[2].trim());
				if(split[3] != null) alphaOff = Std.parseInt(split[3].trim());
				if(splitAlpha[0] != null) redMult = Std.parseInt(splitAlpha[0].trim());
				if(splitAlpha[1] != null) greenMult = Std.parseInt(splitAlpha[1].trim());
				if(splitAlpha[2] != null) blueMult = Std.parseInt(splitAlpha[2].trim());
				if(splitAlpha[3] != null) alphaMult = Std.parseInt(splitAlpha[3].trim());

				if (flValue4 == null || flValue4 == 0)
					flValue4 = 1;

				var ease = LuaUtils.getTweenEaseByString(value5);

				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'dad':
						char = dad;
					case 'mom':
						char = mom;
					case 'bro':
						char = bro;
					default:
						char = boyfriend;
				}
				
				FlxTween.tween(char.colorTransform, {redOffset: redOff, greenOffset: greenOff, blueOffset: blueOff, alphaOffset: alphaOff, redMultiplier: redMult, greenMultiplier: greenMult, blueMultiplier: blueMult, alphaMultiplier: alphaMult}, flValue4 / playbackRate, {ease: ease});

			case 'Update Vocals':
				vocals.volume = 1;
				opponentVocals.volume = 1;
				resyncVocals();

			case 'Character Visibility':
				if(ClientPrefs.data.optimize) return;

				var char:Character = boyfriend;
				var val2:Int = Std.parseInt(value2);

				if (flValue3 == null)
					flValue3 = 1;

				var ease = LuaUtils.getTweenEaseByString(value4);
				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'dad':
						char = dad;
					case 'mom':
						char = mom;
					case 'bro':
						char = bro;
					default:
						char = boyfriend;
				}

				if (Math.isNaN(val2))
					val2 = 0xFFFFFFFF;

				FlxTween.cancelTweensOf(char);
				FlxTween.tween(char, {alpha: flValue2}, flValue3 / playbackRate, {ease: ease});

			case 'Strumline Visibility':
				var strum:FlxTypedGroup<StrumNote>;

				var ease = LuaUtils.getTweenEaseByString(value4);
						
				if (Math.isNaN(flValue2))
					flValue2 = 1;
						
				if (Math.isNaN(flValue3) || flValue3 <= 0)
					flValue3 = 0.01;
						
				switch (value1)
					{
						case 'dad' | 'opponent':
						{
							strum = opponentStrums;
						
							if (ClientPrefs.data.middleScroll)
								flValue3 *= 0.35;
						}
						default:
							strum = playerStrums;
					}

				for (i in 0...strum.members.length)
				{
					FlxTween.cancelTweensOf(strum.members[i]);
					FlxTween.tween(strum.members[i], {alpha: flValue2}, flValue3 / playbackRate, {ease: ease});
				}

			case 'UI visibilty':
				FlxTween.tween(camHUD, {alpha: flValue1}, flValue2, {ease: FlxEase.linear});

			case 'Fire BOOM':
				if (health >= 0.5) health -=  0.1;

				if (!ClientPrefs.data.lowQuality)
				{
					fireHalapeno.alpha = 1;
					fireHalapeno.animation.play('idle', true);
				}
			
				if (ClientPrefs.data.flashing)
					fireFlash.alpha = 0.4;

				if(ClientPrefs.data.camZooms)
				{
					cameraBopMultiplier += 0.02;
					camHUD.zoom += 0.02;
				}

			case 'Zombie Eat':
				var goNahui:Float = 0;
				eatin = false;
				wave2Zom.animation.play('idle');

				if(initScroll)
				{
					if(value1 == 'on')
						goNahui = iconP2.y + 15;
					else
						goNahui = iconP2.y - 250;
				}
				else
				{
					if(value1 == 'on')
						goNahui = iconP2.y + 15;
					else
						goNahui = iconP2.y + 250;
				}
				FlxTween.cancelTweensOf(wave2Zom);
				FlxTween.tween(wave2Zom, {y: goNahui}, 1 / playbackRate, {ease: FlxEase.backInOut});

			case 'Zombie Gimmick':
				wave2Zom.animation.play('eat');
				eatin = true;
				if(flValue1 == null || flValue1 < 1) flValue1 = 8; 
				speedEater = Math.round(flValue1);

				if(flValue2 == null || flValue2 < 1) flValue1 = 0; 
				whenEat = Math.round(flValue2);

			case 'Jackson Activate':
				jacksonYapping();

			case 'Jackson Stop':
				FlxTween.cancelTweensOf(jacksonDrain);
				jackTime.cancel();

				if(ClientPrefs.data.downScroll)
					FlxTween.tween(jacksonDrain, {y: iconP2.y - 250}, 0.5, {ease: FlxEase.backInOut});
				else
					FlxTween.tween(jacksonDrain, {y: iconP2.y + 250}, 0.5, {ease: FlxEase.backInOut});

			case 'Cinematic Bars':
				var bools:Bool = false;

				switch(value1)
				{
					case 'true':
						bools = true;
					default:
						bools = false;
				}

				cinematicBars(bools, flValue2, flValue3);

			case 'bg hypno':
				if(hypnoBg == null) return;
	
				hypnoBg.visible = !hypnoBg.visible;
				hypnoBg.videoSprite.setGraphicSize(FlxG.width * 2, FlxG.height * 2); //я честно

			case 'Force Dance':
				var char:Character = dad;
				switch (value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					case 'bro' | 'third':
						char = bro;
					case 'mom' | 'second':
						char = mom;
				}
				char.specialAnim = false;
				char.dance(true);

			case 'Respawn Clear': //for tasks
			    if (task != null) task.destroy(); //если хочешь то вот

			case 'Set Property':
				try
				{
					var trueValue:Dynamic = value2.trim();
					if (trueValue == 'true' || trueValue == 'false') trueValue = trueValue == 'true';
					else if (flValue2 != null) trueValue = flValue2;
					else trueValue = value2;

					var split:Array<String> = value1.split('.');
					if(split.length > 1) {
						LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1], trueValue);
					} else {
						LuaUtils.setVarInArray(this, value1, trueValue);
					}
				}
				catch(e:Dynamic)
				{
					var len:Int = e.message.indexOf('\n') + 1;
					if(len <= 0) len = e.message.length;
					#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
					addTextToDebug('ERROR ("Set Property" Event) - ' + e.message.substr(0, len), FlxColor.RED);
					#else
					FlxG.log.warn('ERROR ("Set Property" Event) - ' + e.message.substr(0, len));
					#end
				}

			case 'Show Song':
				var val1:Int = Std.parseInt(value1);
					if (Math.isNaN(val1))
						val1 = -1;

				if (task != null) task.destroy(); //если хочешь то вот

				task = new SongIntro(0, 0, SONG.song.toLowerCase().replace(' ', '-'), Std.parseInt(value1));
				task.cameras = [camOther];
				add(task);
				if (task != null) task.start(); //если хочешь то вот

			case 'Play Sound':
				if(flValue2 == null) flValue2 = 1;
				FlxG.sound.play(Paths.sound(value1), flValue2);

			case 'Play Video':
				switch(value1)
				{
					case 'sequence 2':
						//sequence2.play();	

					case 'sequences':
						if (!ClientPrefs.data.lowQuality && !ClientPrefs.data.optimize)
						{
							if(sequences.alpha == 1)
								sequences.alpha = 0.001;
							else
								sequences.alpha = 1;
						}
				}
		}

		stagesFunc(function(stage:BaseStage) stage.eventCalled(eventName, value1, value2, value3, value4, value5, flValue1, flValue2, flValue3, flValue4, flValue5, strumTime));
		callOnScripts('onEvent', [eventName, value1, value2, value3, value4, value5, strumTime]);
	}

	public function moveCameraSection(?sec:Null<Int>):Void {
		if(sec == null) sec = curSection;
		if(sec < 0) sec = 0;

		if(SONG.notes[sec] == null) return;

		if (gf != null && SONG.notes[sec].gfSection)
		{
			callOnScripts('onMoveCamera', ['gf']);
			stagesFunc(function(stage:BaseStage) stage.onCameraFocus('gf'));
			return;
		}

		var isDad:Bool = (SONG.notes[sec].mustHitSection != true);
		if (isDad)
			callOnScripts('onMoveCamera', ['dad']);
		else
			callOnScripts('onMoveCamera', ['boyfriend']);

		stagesFunc(function(stage:BaseStage) stage.onCameraFocus(isDad ? 'dad' : 'boyfriend'));
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		updateTime = false;
		FlxG.sound.music.volume = 0;

		vocals.volume = 0;
		vocals.pause();
		opponentVocals.volume = 0;
		opponentVocals.pause();

		if(songName == 'unfuckable')
		{
			beatusVocals.volume = 0;
			beatusVocals.pause();
		}
	
		if(ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset) {
			endCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer) {
				endCallback();
			});
		}
	}


	public var transitioning = false;
	var songData = SONG;
	var random:Bool = false;
	public function reloadSong()
	{
		Conductor.songPosition = 0;
		FlxG.sound.music.time = 0;
		vocals.time = 0;

		if(FlxG.random.bool(50)) 
			random = true;
		else
			random = false;

		FlxG.sound.music.play();
		vocals.play();

		sectionHit();
        stepHit();
        beatHit();
        lastBeatHit = -1;
        lastStepHit = -1;

        unspawnNotes = [];
        eventNotes = [];
        while(notes.length > 0) {
			var daNote = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}

		try
		{
			var eventsChart:SwagSong = Song.getChart('events', songName);
			if(eventsChart != null)
				for (event in eventsChart.events) //Event Notes
					for (i in 0...event[1].length)
						makeEvent(event, i);
		}
		catch(e:Dynamic) {}

		var oldNote:Note = null;
		var sectionsData:Array<SwagSection> = PlayState.SONG.notes;
		var ghostNotesCaught:Int = 0;
		var daBpm:Float = Conductor.bpm;
	
		for (section in sectionsData)
		{
			if (section.changeBPM != null && section.changeBPM && section.bpm != null && daBpm != section.bpm)
				daBpm = section.bpm;

			for (i in 0...section.sectionNotes.length)
			{
				final songNotes: Array<Dynamic> = section.sectionNotes[i];
				var spawnTime: Float = songNotes[0];
				var noteColumn: Int = Std.int(songNotes[1] % totalColumns);
				var holdLength: Float = songNotes[2];
				var noteType: String = !Std.isOfType(songNotes[3], String) ? Note.defaultNoteTypes[songNotes[3]] : songNotes[3];
				if (Math.isNaN(holdLength))
					holdLength = 0.0;

				if(random)
					noteColumn = FlxG.random.int(0, 3);

				var gottaHitNote:Bool = (songNotes[1] < totalColumns);

				if (i != 0) {
					// CLEAR ANY POSSIBLE GHOST NOTES
					for (evilNote in unspawnNotes) {
						var matches: Bool = (noteColumn == evilNote.noteData && gottaHitNote == evilNote.mustPress && evilNote.noteType == noteType);
						if (matches && Math.abs(spawnTime - evilNote.strumTime) < flixel.math.FlxMath.EPSILON) {
							if (evilNote.tail.length > 0)
								for (tail in evilNote.tail)
								{
									tail.destroy();
									unspawnNotes.remove(tail);
								}
							evilNote.destroy();
							unspawnNotes.remove(evilNote);
							ghostNotesCaught++;
							//continue;
						}
					}
				}

				var swagNote:Note = new Note(spawnTime, noteColumn, oldNote);
				var isAlt: Bool = section.altAnim && !gottaHitNote;
				swagNote.gfNote = (section.gfSection && gottaHitNote == section.mustHitSection);
				swagNote.animSuffix = isAlt ? "-alt" : "";
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = holdLength;
				swagNote.noteType = noteType;
	
				swagNote.scrollFactor.set();
				unspawnNotes.push(swagNote);

				var curStepCrochet:Float = 60 / daBpm * 1000 / 4.0;
				final roundSus:Int = Math.round(swagNote.sustainLength / curStepCrochet);
				if(roundSus > 0)
				{
					for (susNote in 0...roundSus)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(spawnTime + (curStepCrochet * susNote), noteColumn, oldNote, true);
						sustainNote.animSuffix = swagNote.animSuffix;
						sustainNote.mustPress = swagNote.mustPress;
						sustainNote.gfNote = swagNote.gfNote;
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						swagNote.tail.push(sustainNote);

						sustainNote.correctionOffset = swagNote.height / 2;

						oldNote.scale.y /= playbackRate;
						oldNote.resizeByRatio(curStepCrochet / Conductor.stepCrochet);

						if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2; // general offset
						else if(ClientPrefs.data.middleScroll)
						{
							sustainNote.x += 310;
							if(noteColumn > 1) //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.data.middleScroll)
				{
					swagNote.x += 310;
					if(noteColumn > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				oldNote = swagNote;
			}
		}
		trace('["${SONG.song.toUpperCase()}" CHART INFO]: Ghost Notes Cleared: $ghostNotesCaught');

		unspawnNotes.sort(sortByTime);
	}

	inline private function createWaveSprite(image:String, antialias:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		spr.cameras = [camHUD];
		spr.scrollFactor.set();
		spr.updateHitbox();

		spr.screenCenter();
		spr.antialiasing = antialias;
		insert(members.indexOf(noteGroup), spr);

		if(image == 'wave')
		{
			FlxG.sound.play(Paths.sound('wave'), 0.3);
			spr.scale.set(2, 2);
			spr.alpha = 0;
			FlxTween.tween(spr, {alpha: 1}, 0.5, {
					ease: FlxEase.sineIn
			});
			FlxTween.tween(spr.scale, {x: 1, y: 1}, 0.5, {
				ease: FlxEase.sineIn,
				onComplete: function(twn:FlxTween)
				{
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxTween.tween(spr, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								remove(spr);
								spr.destroy();
							}
						});
					});
				}
			});
		}

		if(image == 'finalwave')
		{
			spr.scale.set(2, 2);
			spr.alpha = 0;
			FlxTween.tween(spr, {alpha: 1}, 0.3);
			FlxTween.tween(spr.scale, {x: 1, y: 1}, 0.3, {
				ease: FlxEase.expoIn,
				onComplete: function(twn:FlxTween)
				{
					FlxG.sound.play(Paths.sound('final'), 0.3);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxTween.tween(spr, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								remove(spr);
								spr.destroy();
							}
						});
					});
				}
			});
		}

		return spr;
	}

	public function endSong()
	{
		//Should kill you if you tried to cheat
		if(!startingSong)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset)
					health -= 0.05;
			});
			for (daNote in unspawnNotes)
			{
				if(daNote != null && daNote.strumTime < songLength - Conductor.safeZoneOffset)
					health -= 0.05;
			}

			if(doDeathCheck()) {
				return false;
			}
		}

		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		inCutscene = false;
		updateTime = false;

		respawnPoint = 0;
		respawned = false;

		deathCounter = 0;
		seenCutscene = false;

		var ret:Dynamic = callOnScripts('onEndSong', null, true);
		if(ret != LuaUtils.Function_Stop && !transitioning)
		{
			#if !switch
			if(!changedDifficulty)
			{
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(Song.loadedSongName, songScore, storyDifficulty, percent);
			}
			#end
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return false;
			}

			if (isStoryMode)
			{
				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					Mods.loadTopMod();
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

					canResync = false;

					if(changedDifficulty)
					{
						MusicBeatState.switchState(new EndState());
					}
					else
					{
						FlxG.save.data.fucked++;

						if(songMisses == 0) FlxG.save.data.fcUnfuck = true;

						switch(FlxG.save.data.fucked)
						{
							case 5:
								Sys.command('mshta vbscript:Execute("msgbox ""Ты все еще проходишь? Что ты пытаешся найти?"":close")');
							case 10:
								Sys.command('mshta vbscript:Execute("msgbox ""Да, тут есть разные концовки, ивенты и прочее. Но ты еще не устал?"":close")');
							case 15:
								Sys.command('mshta vbscript:Execute("msgbox ""Тебя тут никто не держит, цикл есть цикл, ВСЁ"":close")');
							case 20:
								Sys.command('mshta vbscript:Execute("msgbox ""Ты такой любопытный, как же ты меня заебываешь..."":close")');
							case 25:
								Sys.command('mshta vbscript:Execute("msgbox ""Ты довольно терпиливый, для человека с одной жизнью"":close")');
							case 30:
								Sys.command('mshta vbscript:Execute("msgbox ""Может хватит уже?"":close")');
							case 35:
								Sys.command('mshta vbscript:Execute("msgbox ""Тебе просто нравится страдать или ты реально что то ищешь?"":close")');
							case 40:
								Sys.command('mshta vbscript:Execute("msgbox ""Уже что то нашел? Не давай мне знаков, мне похую"":close")');
							case 45:
								Sys.command('mshta vbscript:Execute("msgbox ""...Ты издеваешься?..."":close")');
							case 50:
								Sys.command('mshta vbscript:Execute("msgbox ""Тебе что занятся нечем?"":close")');
							case 55:
								Sys.command('mshta vbscript:Execute("msgbox ""..."":close")');
							case 60:
								Sys.command('mshta vbscript:Execute("msgbox ""Окей я понял, не буду мешать, на этом моменте мне гига-похуй"":close")');
						}

						if(Init.fun >= 53 && Init.fun <= 65)
							MusicBeatState.switchState(new EndDialogueState());
						else if(Init.fun == 69)
							MusicBeatState.switchState(new FunnyState());
						else
							MusicBeatState.switchState(new EndState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				Mods.loadTopMod();
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

				canResync = false;
				MusicBeatState.switchState(new MainMenuState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
		return true;
	}

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;
			invalidateNote(daNote);
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	// Stores Ratings and Combo Sprites in a group
	public var comboGroup:FlxSpriteGroup;
	// Stores HUD Objects in a Group
	public var uiGroup:FlxSpriteGroup;
	// Stores Note Objects in a Group
	public var noteGroup:FlxTypedGroup<FlxBasic>;

	private function cachePopUpScore()
	{
		var uiFolder:String = "";
		if (stageUI != "normal")
			uiFolder = uiPrefix + "UI/";

		for (rating in ratingsData)
			Paths.image(uiFolder + rating.image + uiPostfix);
		for (i in 0...10)
			Paths.image(uiFolder + 'num' + i + uiPostfix);
	}

	var c_PBOT1_MISS = 160;
	var c_PBOT1_PERFECT = 5;
	var c_PBOT1_SCORING_OFFSET = 54.99;
	var c_PBOT1_SCORING_SLOPE = .08;
	var c_PBOT1_MAX_SCORE = 500;
	var c_PBOT1_MIN_SCORE = 5;
	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
		vocals.volume = 1;

		var score:Int = c_PBOT1_MIN_SCORE;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.hits++;
		note.rating = daRating.name;
		note.hitHealth = daRating.bonusHealth;
		score = daRating.score;

		if (noteDiff < c_PBOT1_PERFECT) score = c_PBOT1_MAX_SCORE;
		else if (noteDiff < c_PBOT1_MISS) {
			var factor:Float = 1.0 - (1.0 / (1.0 + Math.exp(-c_PBOT1_SCORING_SLOPE * (noteDiff - c_PBOT1_SCORING_OFFSET))));
			score = Std.int(c_PBOT1_MAX_SCORE * factor + c_PBOT1_MIN_SCORE);
		}

		if(daRating.noteSplash && !note.noteSplashData.disabled)
			spawnNoteSplashOnNote(note);

		if(daRating.grayNote)
		{
			combo = 0;
			grayNoteEarly(note);
		}

		if(!cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		FlxTween.cancelTweensOf(ratingTxt);
		FlxTween.cancelTweensOf(ratingTxt.alpha);
		ratingTxt.alpha = 1;
		ratingTxt.text = daRating.image.toUpperCase() + ' x' + combo;

		if(initScroll) 
			ratingTxt.y = healthBar.y + 75;
		else
			ratingTxt.y = healthBar.y - 100;
		
		if(initScroll) 
			FlxTween.tween(ratingTxt, {y: healthBar.y + 50}, Conductor.crochet * 0.002 / playbackRate, {ease: FlxEase.quadOut});
		else
			FlxTween.tween(ratingTxt, {y: healthBar.y - 125}, Conductor.crochet * 0.002 / playbackRate, {ease: FlxEase.quadOut});
		
		FlxTween.tween(ratingTxt, {alpha: 0}, 0.2 / playbackRate, {startDelay: Conductor.crochet * 0.001 / playbackRate});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{

		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);

		if (!controls.controllerMode)
		{
			#if debug
			//Prevents crash specifically on debug without needing to try catch shit
			@:privateAccess if (!FlxG.keys._keyListMap.exists(eventKey)) return;
			#end

			if(FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) keyPressed(key);
		}
	}

	private function keyPressed(key:Int)
	{
		if(cpuControlled || paused || inCutscene || key < 0 || key >= playerStrums.length || !generatedMusic || endingSong || boyfriend.stunned) return;

		var ret:Dynamic = callOnScripts('onKeyPressPre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		// more accurate hit time for the ratings?
		var lastTime:Float = Conductor.songPosition;
		if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		// obtain notes that the player can hit
		var plrInputNotes:Array<Note> = notes.members.filter(function(n:Note):Bool {
			var canHit:Bool = n != null && !strumsBlocked[n.noteData] && n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit;
			return canHit && !n.isSustainNote && n.noteData == key;
		});
		plrInputNotes.sort(sortHitNotes);

		if (plrInputNotes.length != 0) { // slightly faster than doing `> 0` lol
			var funnyNote:Note = plrInputNotes[0]; // front note

			if (plrInputNotes.length > 1) {
				var doubleNote:Note = plrInputNotes[1];

				if (doubleNote.noteData == funnyNote.noteData) {
					// if the note has a 0ms distance (is on top of the current note), kill it
					if (Math.abs(doubleNote.strumTime - funnyNote.strumTime) < 1.0)
						invalidateNote(doubleNote);
					else if (doubleNote.strumTime < funnyNote.strumTime)
					{
						// replace the note if its ahead of time (or at least ensure "doubleNote" is ahead)
						funnyNote = doubleNote;
					}
				}
			}
			goodNoteHit(funnyNote);
		}
		else
		{
			if (ClientPrefs.data.ghostTapping)
				callOnScripts('onGhostTap', [key]);
			else
				noteMissPress(key);
		}

		//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
		Conductor.songPosition = lastTime;

		var spr:StrumNote = playerStrums.members[key];
		if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
		{
			spr.playAnim('pressed');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyPress', [key]);
	}

	public static function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);
		if(!controls.controllerMode && key > -1) keyReleased(key);
	}

	private function keyReleased(key:Int)
	{
		if(cpuControlled || !startedCountdown || paused || key < 0 || key >= playerStrums.length) return;

		var ret:Dynamic = callOnScripts('onKeyReleasePre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		var spr:StrumNote = playerStrums.members[key];
		if(spr != null)
		{
			spr.playAnim('static');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyRelease', [key]);
	}

	public static function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...arr.length)
			{
				var note:Array<FlxKey> = Controls.instance.keyboardBinds[arr[i]];
				for (noteKey in note)
					if(key == noteKey)
						return i;
			}
		}
		return -1;
	}

	// Hold notes
	private function keysCheck():Void
	{
		// HOLDING
		var holdArray:Array<Bool> = [];
		var pressArray:Array<Bool> = [];
		var releaseArray:Array<Bool> = [];
		for (key in keysArray)
		{
			holdArray.push(controls.pressed(key));
			pressArray.push(controls.justPressed(key));
			releaseArray.push(controls.justReleased(key));
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(controls.controllerMode && pressArray.contains(true))
			for (i in 0...pressArray.length)
				if(pressArray[i] && strumsBlocked[i] != true)
					keyPressed(i);

		if (startedCountdown && !inCutscene && !boyfriend.stunned && generatedMusic)
		{
			if (notes.length > 0) {
				for (n in notes) { // I can't do a filter here, that's kinda awesome
					var canHit:Bool = (n != null && !strumsBlocked[n.noteData] && n.canBeHit
						&& n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit);

					canHit = canHit && n.parent != null && n.parent.wasGoodHit;

					if (canHit && n.isSustainNote) {
						var released:Bool = !holdArray[n.noteData];

						if (!released)
							goodNoteHit(n);
					}
				}
			}

			if (!holdArray.contains(true) || endingSong)
				playerDance();
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if((controls.controllerMode || strumsBlocked.contains(true)) && releaseArray.contains(true))
			for (i in 0...releaseArray.length)
				if(releaseArray[i] || strumsBlocked[i] == true)
					keyReleased(i);
	}

	function cameraFromString(cam:String):FlxCamera {
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': return camHUD;
			case 'camother' | 'other': return camOther;
			case 'camhudbehind' | 'hudbehind' | 'video': return camHudBehind;
		}
		return camGame;
	}

	function createLanes()
	{
		if(ClientPrefs.data.laneUnderlay == 0) return;

		laneE0 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneE0.alpha = 0;
		laneE1 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneE1.alpha = 0;
		laneE2 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneE2.alpha = 0;
		laneE3 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneE3.alpha = 0;

		laneP0 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneP0.alpha = 0;
		laneP1 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneP1.alpha = 0;
		laneP2 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneP2.alpha = 0;
		laneP3 = new FlxSprite(0,0).makeGraphic(Std.int(Note.swagWidth) - 5, FlxG.height * 2, FlxColor.BLACK);
		laneP3.alpha = 0;

		uiGroup.add(laneE0);
		uiGroup.add(laneE1);
		uiGroup.add(laneE2);
		uiGroup.add(laneE3);

		uiGroup.add(laneP0);
		uiGroup.add(laneP1);
		uiGroup.add(laneP2);
		uiGroup.add(laneP3);
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1)
				invalidateNote(note);
		});

		final end:Note = daNote.isSustainNote ? daNote.parent.tail[daNote.parent.tail.length - 1] : daNote.tail[daNote.tail.length - 1];
		if (end != null && end.extraData['holdSplash'] != null) {
			end.extraData['holdSplash'].visible = false;
		}

		noteMissCommon(daNote.noteData, daNote);
		stagesFunc(function(stage:BaseStage) stage.noteMiss(daNote));
		var result:Dynamic = callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('noteMiss', [daNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.data.ghostTapping) return; //fuck it

		noteMissCommon(direction, null, true);
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		stagesFunc(function(stage:BaseStage) stage.noteMissPress(direction));
		callOnScripts('noteMissPress', [direction]);
	}

	function noteMissCommon(direction:Int, note:Note = null, ?ghost:Bool = false)
	{
		// score and data
		var subtract:Float = pressMissDamage;
		if(note != null) subtract = note.missHealth;

		// GUITAR HERO SUSTAIN CHECK LOL!!!!
		if (note != null && note.parent == null) {
			if(note.tail.length > 0) {
				note.alpha = 0.35;
				for(childNote in note.tail) {
					childNote.alpha = note.alpha;
					childNote.missed = true;
					childNote.canBeHit = false;
					childNote.ignoreNote = true;
					childNote.tooLate = true;
				}

				note.missed = true;
				note.canBeHit = false;

				//subtract += 0.385; // you take more damage if playing with this gameplay changer enabled.
				// i mean its fair :p -Crow
				subtract *= note.tail.length + 1;
				// i think it would be fair if damage multiplied based on how long the sustain is -Tahir
			}

			if (note.missed)
				return;
		}
		if (note != null && note.parent != null && note.isSustainNote) {
			if (note.missed)
				return;

			var parentNote:Note = note.parent;
			if (parentNote.wasGoodHit && parentNote.tail.length > 0) {
				for (child in parentNote.tail) if (child != note) {
					child.missed = true;
					child.canBeHit = false;
					child.ignoreNote = true;
					child.tooLate = true;
				}
			}
		}

		if(instakillOnMiss)
		{
			vocals.volume = 0;
			opponentVocals.volume = 0;
			if(songName == 'unfuckable') beatusVocals.volume = 0;
			doDeathCheck(true);
		}

		var lastCombo:Int = combo;

		if(!ghost)
		{
			combo = 0;
			if(!endingSong) songMisses++;
			totalPlayed++;
			RecalculateRating(true);
		}

		health -= subtract;
		songScore -= 10;

		// play character anims
		var char:Character = boyfriend;
		if((note != null && note.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) char = gf;

		if(char != null && (note == null || !note.noMissAnimation) && char.hasMissAnimations)
		{
			var postfix:String = '';
			if(note != null) postfix = note.animSuffix;

			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss' + postfix;
			char.playAnim(animToPlay, true);

			if(char != gf && lastCombo > 5 && gf != null && gf.hasAnimation('sad'))
			{
				gf.playAnim('sad');
				gf.specialAnim = true;
			}
		}
		vocals.volume = 0;
	}

	function opponentNoteHit(note:Note):Void
	{
		var result:Dynamic = callOnLuas('opponentNoteHitPre', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) result = callOnHScript('opponentNoteHitPre', [note]);

		if(result == LuaUtils.Function_Stop) return;

		if(note.noteType == 'Hey!' && dad.hasAnimation('hey'))
		{
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		}
		else if(!note.noAnimation)
		{
			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + note.animSuffix;
			if(note.gfNote) char = gf;

			if(note.noteType == "POLE NOTE" || note.noteType == "POLE NOTE ALT" || note.noteType == "POLE NOTE NO ANIM") char = mom;

			if(note.noteType == "JACK NOTE" || note.noteType == "JACK NOTE ALT" || note.noteType == "JACK NOTE NO ANIM") char = bro;

			if(note.noteType == "BEATUS POLE") char = mom;

			if(note.noteType == "BEATUS ALL" || note.noteType == "FINAL")
			{
				if(!note.isSustainNote) mom.playAnim(animToPlay, true);
				mom.holdTimer = 0;

				if(!note.isSustainNote) bro.playAnim(animToPlay, true);
				bro.holdTimer = 0;
			}

			if(char != null)
			{
				if(!note.isSustainNote) char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if(opponentVocals.length <= 0 || SONG.song == 'ezqsvf') vocals.volume = 1;
		strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);
		note.hitByOpponent = true;

		spawnHoldSplashOnNote(note);

		if (opponentHealthDrain && health >= opponentHealthDrainAmount)
			health -= opponentHealthDrainAmount;

		if (singingShakeArray[1])
		{
			camGame.shake(0.005, 0.2);
			camHUD.shake(0.005, 0.2);
			camHudBehind.shake(0.005, 0.2);
		}

		if(!note.noAnimation)
		{
			if(SONG.notes[curSection] != null && !SONG.notes[curSection].mustHitSection)
			{
				FlxG.camera.targetOffset.set(0,0);
				switch(note.noteData)
				{
					case 0:
						FlxG.camera.targetOffset.x = -nOffset;
					case 1:
						FlxG.camera.targetOffset.y = nOffset;
					case 2:
						FlxG.camera.targetOffset.y = -nOffset;
					case 3:
						FlxG.camera.targetOffset.x = nOffset;
				}
			}
		}

		if(ghostToggle && !note.isSustainNote && ClientPrefs.data.flashing)
		{
			var xToMove:Float = 0;

			left = !left;

			if(left)
				xToMove = FlxG.random.float(DAD_X - 400, DAD_X - 100);
			else
				xToMove = FlxG.random.float(DAD_X + 100, DAD_X + 400);
			
			bro.alpha = 0.6;
			broGroup.x = xToMove;

			mom.alpha = 0.6;
			momGroup.x = xToMove;
		}
		
		stagesFunc(function(stage:BaseStage) stage.opponentNoteHit(note));
		var result:Dynamic = callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('opponentNoteHit', [note]);

		if (!note.isSustainNote) invalidateNote(note);
	}

	public function goodNoteHit(note:Note):Void
	{
		if(note.wasGoodHit) return;
		if(cpuControlled && note.ignoreNote) return;

		var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;

		var result:Dynamic = callOnLuas('goodNoteHitPre', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) result = callOnHScript('goodNoteHitPre', [note]);

		if(result == LuaUtils.Function_Stop) return;

		note.wasGoodHit = true;

		note.noteWasHit = true; //пиздец что эту переменную не использовали

		if (note.hitsoundVolume > 0 && !note.hitsoundDisabled)
			FlxG.sound.play(Paths.sound(note.hitsound), note.hitsoundVolume);

		if(!note.hitCausesMiss) //Common notes
		{
			if(!note.noAnimation)
			{
				var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + note.animSuffix;

				var char:Character = boyfriend;
				var animCheck:String = 'hey';
				if(note.gfNote)
				{
					char = gf;
					animCheck = 'cheer';
				}

				if(char != null)
				{
					if(!note.isSustainNote) char.playAnim(animToPlay, true);
					char.holdTimer = 0;

					if(note.noteType == 'Hey!')
					{
						if(char.hasAnimation(animCheck))
						{
							char.playAnim(animCheck, true);
							char.specialAnim = true;
							char.heyTimer = 0.6;
						}
					}
				}
			}

			if(!cpuControlled)
			{
				var spr = playerStrums.members[note.noteData];
				if(spr != null) spr.playAnim('confirm', true, [note.rgbShader.r, note.rgbShader.g, note.rgbShader.b]);
			}
			else strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);

			vocals.volume = 1;

			spawnHoldSplashOnNote(note);

			if (!note.isSustainNote)
			{
				combo++;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			}

			if(!note.isSustainNote) health += note.hitHealth;

		}
		else //Notes that count as a miss if you hit them (Hurt notes for example)
		{
			if(!note.noMissAnimation)
			{
				switch(note.noteType)
				{
					case 'Hurt Note':
						if(boyfriend.hasAnimation('hurt'))
						{
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
			}

			noteMiss(note);
			if(!note.noteSplashData.disabled && !note.isSustainNote) spawnNoteSplashOnNote(note);
		}

		if(!note.noAnimation)
		{
			if(SONG.notes[curSection] != null && SONG.notes[curSection].mustHitSection)
			{
				FlxG.camera.targetOffset.set(0,0);
				switch(note.noteData)
				{
					case 0:
						FlxG.camera.targetOffset.x = -nOffset;
					case 1:
						FlxG.camera.targetOffset.y = nOffset;
					case 2:
						FlxG.camera.targetOffset.y = -nOffset;
					case 3:
						FlxG.camera.targetOffset.x = nOffset;
				}
			}
		}

		if (singingShakeArray[0])
		{
			camGame.shake(0.005, 0.2);
			camHUD.shake(0.005, 0.2);
			camHudBehind.shake(0.005, 0.2);
		}

		stagesFunc(function(stage:BaseStage) stage.goodNoteHit(note));
		var result:Dynamic = callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('goodNoteHit', [note]);
		if(!note.isSustainNote && !note.badassed) invalidateNote(note);
	}

	public function invalidateNote(note:Note):Void {
		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	public function grayNoteEarly(note:Note):Void {
		note.rgbShader.r = 0xFFFFFFFF;
		note.rgbShader.g = 0xFFFFFFFF;
		note.rgbShader.b = 0xFF454545;

		note.alpha = 0.5;
		note.multAlpha = 0.5;
		note.ignoreNote = true;
		note.blockHit = true;
		note.badassed = true;
		note.active = false;
	}

	public function spawnHoldSplashOnNote(note:Note) {
		if (!note.isSustainNote && note.tail.length != 0 && note.tail[note.tail.length - 1].extraData['holdSplash'] == null) {
			spawnHoldSplash(note);
		} else if (note.isSustainNote) {
			final end:Note = StringTools.endsWith(note.animation.curAnim.name, 'end') ? note : note.parent.tail[note.parent.tail.length - 1];
			if (end != null) {
				var leSplash:SustainSplash = end.extraData['holdSplash'];
				if (leSplash == null && !end.parent.wasGoodHit) {
					spawnHoldSplash(end);
				} else if (leSplash != null) {
					leSplash.visible = true;
				}
			}
		}
	}

	public function spawnHoldSplash(note:Note) {
		var end:Note = note.isSustainNote ? note.parent.tail[note.parent.tail.length - 1] : note.tail[note.tail.length - 1];
		var splash:SustainSplash = grpHoldSplashes.recycle(SustainSplash);
		splash.setupSusSplash(strumLineNotes.members[note.noteData + (note.mustPress ? 4 : 0)], note, playbackRate);
		grpHoldSplashes.add(end.extraData['holdSplash'] = splash);
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null)
				spawnNoteSplash(strum.x, strum.y, note.noteData, note, strum);
		}
	}

	public function spawnNoteSplash(x:Float = 0, y:Float = 0, ?data:Int = 0, ?note:Note, ?strum:StrumNote) {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.babyArrow = strum;
		splash.spawnSplashNote(x, y, data, note);
		grpNoteSplashes.add(splash);
	}

	override function destroy() {
		camGame.bgColor = 0xFF000000;

		if (psychlua.CustomSubstate.instance != null)
		{
			closeSubState();
			resetSubState();
		}

		if(videoCutscene != null) videoCutscene.destroy();
		//if(sequence2 != null) sequence2.destroy();
		if(sequences != null) sequences.destroy();
		if(hypnoBg != null) hypnoBg.destroy();

		#if LUA_ALLOWED
		for (lua in luaArray)
		{
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = null;
		FunkinLua.customFunctions.clear();
		#end

		Lib.application.window.title = "Friday Night Funkin' BRUTAL PIZDEC Impotence DLC";

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				var ny:Dynamic = script.get('onDestroy');
				if(ny != null && Reflect.isFunction(ny)) ny();
				script.destroy();
			}

		hscriptArray = null;
		#end
		stagesFunc(function(stage:BaseStage) stage.destroy());

		/*if(sequence2 != null)
		{
			sequence2.destroy();
			sequence2 = null;
		}*/

		if(sequences != null)
		{
			sequences.destroy();
			sequences = null;
		}

		if(hypnoBg != null)
		{
			hypnoBg.destroy();
			hypnoBg = null;
		}

		if(videoCutscene != null)
		{
			videoCutscene.destroy();
			videoCutscene = null;
		}

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		FlxG.camera.setFilters([]);

		#if FLX_PITCH FlxG.sound.music.pitch = 1; #end
		FlxG.animationTimeScale = 1;

		Note.globalRgbShaders = [];
		backend.NoteTypesConfig.clearNoteTypesData();

		NoteSplash.configs.clear();
		instance = null;
		super.destroy();
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		if (goHealthDamageBeat && curStep % Math.round(beatHealthStep) == 0) // :3 fuck my ass
			if (health >= beatHealthDrain)
				health -= beatHealthDrain;

		if (eatin && curStep % Math.round(speedEater) == Math.round(whenEat)) //ээээ зомбэ
		{
			if (health >= 0.5)
				health -= 0.1;

			FlxTween.cancelTweensOf(iconP1.colorTransform);

			iconP1.colorTransform.redOffset = 155;
			iconP1.colorTransform.greenOffset = 155;
			iconP1.colorTransform.blueOffset = 155;

			iconP1.colorTransform.redMultiplier = 0.8;
			iconP1.colorTransform.greenMultiplier = 0.8;
			iconP1.colorTransform.blueMultiplier = 0.8;

			FlxTween.tween(iconP1.colorTransform, {redOffset: 0, greenOffset: 0, blueOffset: 0, redMultiplier: 1, greenMultiplier: 1, blueMultiplier: 1}, Conductor.crochet * 0.001 / playbackRate);
		}

		super.stepHit();

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
	}

	function cinematicBars(appear:Bool, time:Float = 0.5, offset:Float = 550) //IF (TRUE) MOMENT?????
	{
		if (appear)
		{
			FlxTween.tween(topBar, {y: 0 + offset}, time, {ease: FlxEase.quadOut});
			FlxTween.tween(bottomBar, {y: 550 - offset}, time, {ease: FlxEase.quadOut});
		}
		else
		{
			FlxTween.tween(topBar, {y: -170}, time, {ease: FlxEase.quadOut});
			FlxTween.tween(bottomBar, {y: 720}, time, {ease: FlxEase.quadOut});
		}
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		iconPEP.scale.set(1.2, 1.2);
		iconPEP.updateHitbox();
		iconPOLE.scale.set(1.2, 1.2);
		iconPOLE.updateHitbox();
		iconJACK.scale.set(1.2, 1.2);
		iconJACK.updateHitbox();

		characterBopper(curBeat);

		if (FlxG.camera.zoom < 1.7 && cameraZoomRate > 0 && curBeat % cameraZoomRate == 0 && ClientPrefs.data.camZooms)
		{
			// Set zoom multiplier for camera bop.
			cameraBopMultiplier = cameraBopIntensity;
			// HUD camera zoom still uses old system. To change. (+3%)
			camHUD.zoom += hudCameraZoomIntensity * defaultHUDCameraZoom;
			camHudBehind.zoom += hudCameraZoomIntensity * 1;
			

			if(shakeBeat)
			{
				camGame.shake(0.003, 1 / (Conductor.bpm / 60));
				camHUD.shake(0.003, 1 / (Conductor.bpm / 60));
				camHudBehind.shake(0.003, 1 / (Conductor.bpm / 60));
			}
		}

		super.beatHit();
		lastBeatHit = curBeat;

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}

	public function characterBopper(beat:Int):Void
	{
		if (gf != null && beat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.getAnimationName().startsWith('sing') && !gf.stunned)
			gf.dance();
		if (boyfriend != null && beat % boyfriend.danceEveryNumBeats == 0 && !boyfriend.getAnimationName().startsWith('sing') && !boyfriend.stunned)
			boyfriend.dance();
		if (dad != null && beat % dad.danceEveryNumBeats == 0 && !dad.getAnimationName().startsWith('sing') && !dad.stunned)
			dad.dance();
		if (mom != null && beat % mom.danceEveryNumBeats == 0 && !mom.getAnimationName().startsWith('sing') && !mom.stunned)
			mom.dance();
		if (bro != null && beat % bro.danceEveryNumBeats == 0 && !bro.getAnimationName().startsWith('sing') && !bro.stunned)
			bro.dance();
	}

	public function playerDance():Void
	{
		var anim:String = boyfriend.getAnimationName();
		if(boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 #if FLX_PITCH / FlxG.sound.music.pitch #end) * boyfriend.singDuration && anim.startsWith('sing') && !anim.endsWith('miss'))
			boyfriend.dance();
	}

	override function sectionHit()
	{
		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong)
				moveCameraSection();

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.bpm = SONG.notes[curSection].bpm;
				setOnScripts('curBpm', Conductor.bpm);
				setOnScripts('crochet', Conductor.crochet);
				setOnScripts('stepCrochet', Conductor.stepCrochet);
			}

			var targetX:Float = SONG.notes[curSection].followX;
			var targetY:Float = SONG.notes[curSection].followY;

			if (SONG.notes[curSection].followCam)
			{
				switch (SONG.notes[curSection].charFollow.toLowerCase())
				{
					case "bf":
						targetX += boyfriend.getMidpoint().x - boyfriend.cameraPosition[0] + boyfriendCameraOffset[0] - 100;
						targetY += boyfriend.getMidpoint().y + boyfriend.cameraPosition[1] + boyfriendCameraOffset[1] - 100;
					default:
						targetX += dad.getMidpoint().x + dad.cameraPosition[0] + opponentCameraOffset[0] + 150;
						targetY += dad.getMidpoint().y + dad.cameraPosition[1] + opponentCameraOffset[1] - 100;
				}
	
				var ease:String = SONG.notes[curSection].tweenFollow;
			
				switch (ease)
				{
					case 'CLASSIC': // Old-school. No ease. Just set follow point.
						resetCamera(false, false, false);
						cancelCameraFollowTween();
						cameraFollowPoint.setPosition(targetX, targetY);
					case 'INSTANT': // Instant ease. Duration is automatically 0.
						tweenCameraToPosition(targetX, targetY, 0);
					default:
						var durSeconds:Float = Conductor.stepCrochet * SONG.notes[curSection].followTime / 1000;
						tweenCameraToPosition(targetX, targetY, durSeconds, LuaUtils.getTweenEaseByString(ease));
				}
			}

			if (SONG.notes[curSection].zoomCam)
			{
				var ease:String = SONG.notes[curSection].tweenZoom;

				switch(ease)
				{
					case "INSTANT":
						tweenCameraZoom(SONG.notes[curSection].zoom, 0, SONG.notes[curSection].stgZoom);
					default:
						var durSeconds:Float = Conductor.stepCrochet * SONG.notes[curSection].zoomTime / 1000;
						tweenCameraZoom(SONG.notes[curSection].zoom, durSeconds, SONG.notes[curSection].stgZoom, LuaUtils.getTweenEaseByString(ease));
				}
			}

			setOnScripts('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnScripts('altAnim', SONG.notes[curSection].altAnim);
			setOnScripts('gfSection', SONG.notes[curSection].gfSection);
		}
		super.sectionHit();

		setOnScripts('curSection', curSection);
		callOnScripts('onSectionHit');
	}

	function jacksonYapping()
	{
		jackTime = new FlxTimer().start(8, function(tmr:FlxTimer)
		{
			jacksonDrain.flipX = false;
			FlxTween.tween(jacksonDrain, {x: 500}, 3,
			{
				onComplete: function(_) {
					jacksonDrain.flipX = true;
					FlxTween.tween(jacksonDrain, {x: -500}, 3);
				}
			});
		}, 0);
	}

	function setupCameraToSong()
	{
		switch(songName)
		{
			default:
				cameraFollowPoint.setPosition(dad.getMidpoint().x + dad.cameraPosition[0] + opponentCameraOffset[0] + 150, dad.getMidpoint().y + dad.cameraPosition[1] + opponentCameraOffset[1] - 100);
		}
	}

	function resetCameraZoom():Void
	{
		// Apply camera zoom level from stage data.
		currentCameraZoom = stageZoom;
		FlxG.camera.zoom = currentCameraZoom;
		
		// Reset bop multiplier.
		cameraBopMultiplier = 1.0;
	}
		
	public function resetCamera(?resetZoom:Bool = true, ?cancelTweens:Bool = true, ?snap:Bool = true):Void
	{
		resetZoom = resetZoom ?? true;
		cancelTweens = cancelTweens ?? true;
		
		// Cancel camera tweens if any are active.
		if (cancelTweens)
			cancelAllCameraTweens();
		
		FlxG.camera.follow(cameraFollowPoint, FlxCameraFollowStyle.LOCKON, 0.04);
		FlxG.camera.targetOffset.set();
		
		if (resetZoom)
			resetCameraZoom();
		
		// Snap the camera to the follow point immediately.
		if (snap) FlxG.camera.focusOn(cameraFollowPoint.getPosition());
	}
		
	function tweenCameraToPosition(?x:Float, ?y:Float, ?duration:Float, ?ease:Null<Float->Float>):Void
	{
		cameraFollowPoint.setPosition(x, y);
		tweenCameraToFollowPoint(duration, ease);
	}
		
	/**
	* Disables camera following and tweens the camera to the follow point manually.
	*/
	function tweenCameraToFollowPoint(?duration:Float, ?ease:Null<Float->Float>):Void
	{
		// Cancel the current tween if it's active.
		cancelCameraFollowTween();
		
		if (duration == 0)
		{
			// Instant movement. Just reset the camera to force it to the follow point.
			resetCamera(false, false);
		}
		else
		{
			// Disable camera following for the duration of the tween.
			FlxG.camera.target = null;
		
			// Follow tween! Caching it so we can cancel/pause it later if needed.
			var followPos:FlxBasePoint = FlxBasePoint.get(cameraFollowPoint.x - FlxG.camera.width * .5, cameraFollowPoint.y - FlxG.camera.height * .5);
			cameraFollowTween = FlxTween.tween(FlxG.camera.scroll, {x: followPos.x, y: followPos.y}, duration / playbackRate,
			{
				ease: ease,
				onComplete: function(_) {
					resetCamera(false, false); // Re-enable camera following when the tween is complete.
				}
			});
		}
	}
		
	function cancelCameraFollowTween()
	{
		if (cameraFollowTween != null)
			cameraFollowTween.cancel();
	}
		
	/**
	* Tweens the camera zoom to the desired amount.
	*/
	public function tweenCameraZoom(?zoom:Float, ?duration:Float, ?direct:Bool, ?ease:EaseFunction):Void
	{
		// Cancel the current tween if it's active.
		cancelCameraZoomTween();
		
		// Direct mode: Set zoom directly.
		// Stage mode: Set zoom as a multiplier of the current stage's default zoom.
		var targetZoom = zoom * (direct ? 1.0 : stageZoom);
		
		if (duration == 0)
			// Instant zoom. No tween needed.
			currentCameraZoom = targetZoom;
		else
			// Zoom tween! Caching it so we can cancel/pause it later if needed.
			cameraZoomTween = FlxTween.num(
				currentCameraZoom,
				targetZoom,
				duration / playbackRate,
				{ease: ease},
				function(num:Float) {currentCameraZoom = num;}
			);
	}
		
	function cancelCameraZoomTween()
	{
		if (cameraZoomTween != null)
			cameraZoomTween.cancel();
	}
		
	function cancelAllCameraTweens()
	{
		cancelCameraFollowTween();
		cancelCameraZoomTween();
	}

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String)
	{
		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(!FileSystem.exists(luaToLoad))
			luaToLoad = Paths.getSharedPath(luaFile);

		if(FileSystem.exists(luaToLoad))
		#elseif sys
		var luaToLoad:String = Paths.getSharedPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		#end
		{
			for (script in luaArray)
				if(script.scriptName == luaToLoad) return false;

			new FunkinLua(luaToLoad);
			return true;
		}
		return false;
	}
	#end

	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String)
	{
		#if MODS_ALLOWED
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getSharedPath(scriptFile);
		#else
		var scriptToLoad:String = Paths.getSharedPath(scriptFile);
		#end

		if(FileSystem.exists(scriptToLoad))
		{
			if (Iris.instances.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public function initHScript(file:String)
	{
		var newScript:HScript = null;
		try
		{
			newScript = new HScript(null, file);
			if (newScript.exists('onCreate')) newScript.call('onCreate');
			trace('initialized hscript interp successfully: $file');
			hscriptArray.push(newScript);
		}
		catch(e:Dynamic)
		{
			addTextToDebug('ERROR ON LOADING ($file) - $e', FlxColor.RED);
			var newScript:HScript = cast (Iris.instances.get(file), HScript);
			if(newScript != null)
				newScript.destroy();
		}
	}
	#end

	public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:String = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:String = LuaUtils.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var arr:Array<FunkinLua> = [];
		for (script in luaArray)
		{
			if(script.closed)
			{
				arr.push(script);
				continue;
			}

			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if(script.closed) arr.push(script);
		}

		if(arr.length > 0)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:String = LuaUtils.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(LuaUtils.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;

		for(script in hscriptArray)
		{
			@:privateAccess
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			try
			{
				var callValue = script.call(funcToCall, args);
				var myValue:Dynamic = callValue.returnValue;

				if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
				{
					returnVal = myValue;
					break;
				}

				if(myValue != null && !excludeValues.contains(myValue))
					returnVal = myValue;
			}
			catch(e:Dynamic)
			{
				addTextToDebug('ERROR (${script.origin}: $funcToCall) - $e', FlxColor.RED);
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Float, note:Note) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = opponentStrums.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true, [note.rgbShader.r, note.rgbShader.g, note.rgbShader.b]);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false, scoreBop:Bool = true) {
		setOnScripts('score', songScore);
		setOnScripts('misses', songMisses);
		setOnScripts('hits', songHits);
		setOnScripts('combo', combo);

		var ret:Dynamic = callOnScripts('onRecalculateRating', null, true);
		if(ret != LuaUtils.Function_Stop)
		{
			ratingName = '?';
			if(totalPlayed != 0) //Prevent divide by 0
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				if(ratingPercent < 1)
					for (i in 0...ratingStuff.length-1)
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
			}
			fullComboFunction();
		}
		setOnScripts('rating', ratingPercent);
		setOnScripts('ratingName', ratingName);
		setOnScripts('ratingFC', ratingFC);
		setOnScripts('totalPlayed', totalPlayed);
		setOnScripts('totalNotesHit', totalNotesHit);
		updateScore(badHit, scoreBop); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.data.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (MODS_ALLOWED && !flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'shaders/'))
		{
			var frag:String = folder + name + '.frag';
			var vert:String = folder + name + '.vert';
			var found:Bool = false;
			if(FileSystem.exists(frag))
			{
				frag = File.getContent(frag);
				found = true;
			}
			else frag = null;

			if(FileSystem.exists(vert))
			{
				vert = File.getContent(vert);
				found = true;
			}
			else vert = null;

			if(found)
			{
				runtimeShaders.set(name, [frag, vert]);
				//trace('Found shader $name!');
				return true;
			}
		}
			#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
			addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
			#else
			FlxG.log.warn('Missing shader $name .frag AND .vert files!');
			#end
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		#end
		return false;
	}
	#end
}
