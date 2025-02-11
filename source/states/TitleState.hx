package states;

import backend.WeekData;

import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import states.StoryMenuState;
import states.MainMenuState;

import openfl.filters.ShaderFilter;
import openfl.filters.BlurFilter;

import shaders.VCRMario85;
import shaders.ShadersHandler;

typedef TitleData =
{
	var startx:Float;
	var starty:Float;
	var bpm:Float;
}

class TitleState extends MusicBeatState
{
	var credGroup:FlxGroup = new FlxGroup();
	var textGroup:FlxGroup = new FlxGroup();
	var curWacky:Array<String> = [];

	var credTextShit:Alphabet;

	public static var initialized:Bool = false;
	public static var gotFromTitle:Bool = true;

	public var vcr:VCRMario85;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		FlxG.save.data.firstTime = false;
		FlxG.save.flush();

		if(!initialized)
		{
			persistentUpdate = true;
			persistentDraw = true;
		}

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		add(credGroup);

		curWacky = FlxG.random.getObject(getIntroTextShit());

		FlxG.mouse.visible = false;

		createCoolText([curWacky[0]]);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			addMoreText(curWacky[1]);
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				deleteCoolText();
				startIntro();
			});
		});

		vcr = new VCRMario85();

		if(ClientPrefs.data.tvEffect)
		{
			FlxG.camera.setFilters([ShadersHandler.chromaticAberration, ShadersHandler.radialBlur, new ShaderFilter(vcr)]);
			ShadersHandler.setChrome(0);
		}
	}

	var logoBl:FlxSprite;
	var titleText:FlxSprite;

	function startIntro()
	{
		persistentUpdate = true;
		if (!initialized)
		{
			FlxG.sound.playMusic(Paths.music('ZondriePerec'), 0.7);
			FlxG.sound.music.time = 78866;

			FlxG.camera.shake(0.03, 4, function() //я гений
			{
				FlxG.camera.shake(0.02, 0.15, function() 
				{
					FlxG.camera.shake(0.01, 0.15, function() 
					{
						FlxG.camera.shake(0.005, 0.15);
					});
				});
			});
		}

		Conductor.bpm = 146;

		logoBl = new FlxSprite(0, 0).loadGraphic(Paths.image('logo'));
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		logoBl.updateHitbox();
		logoBl.screenCenter();

		add(logoBl); //FNF Logo

		FlxG.camera.flash(FlxColor.RED, 4);

		FlxTween.tween(FlxG.camera, {zoom: 3}, 8, {ease: FlxEase.expoIn});

		new FlxTimer().start(7.8, function(tmr:FlxTimer)
		{
			FlxG.camera.flash(FlxColor.BLACK, 999);
			FlxTransitionableState.skipNextTransOut = true;
			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new MainMenuState());
			});
		});
	}

	var musicBPM:Float = 102;
	var pressed:Bool = false;
	var transitioning:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		super.update(elapsed);

		if(ClientPrefs.data.tvEffect)
		{
			vcr.update(elapsed);
			ShadersHandler.setChrome(FlxG.random.int(2,6)/1000);
			ShadersHandler.setRadialBlur(640, 360,  FlxG.random.float(0.001, 0.01));
		}
	}

	public static var closedState:Bool = false;
	
	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt');
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}
}
