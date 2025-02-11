package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var disclaimer:FlxText;
	var enterText:FlxText;

	var flashDick:Alphabet;
	var yesText:Alphabet;
	var noText:Alphabet;

	var canChoose:Bool = false;
	var startTimer:FlxTimer;
	var whatWillPlay:Int = 1;

	var botsuka:FlxSprite;
	var rippvzdich:FlxSprite;

	var proceed:Float = 0;
	var proceedMax:Float = 100;
	var skiptext:FlxText;

	var settTxt:FlxText;

	var infoToggled:Bool = false;
	override function create()
	{
		super.create();

		disclaimer = new FlxText(0, 0, FlxG.width, "WARNING!!!", 48);
		disclaimer.setFormat("HouseofTerror.ttf", 80, FlxColor.RED, CENTER);
		disclaimer.alpha = 0.00001;
		disclaimer.y += 120;
		add(disclaimer);

		warnText = new FlxText(0, 0, FlxG.width,
			"This mod contains shaders and bunch of things that can blow up your pc\nRecommending to disable them or atleast turn on Low Quality option\nNot gonna be my fault if it lags for you, pc issue xp",
			32);
		warnText.setFormat("HouseofTerror.ttf", 32, FlxColor.WHITE, CENTER);
		warnText.x += 10;
		warnText.alpha = 0;
		warnText.screenCenter(Y);
		add(warnText);

		botsuka = new FlxSprite().loadGraphic(Paths.image('dolbaeb')); // Это к хваву
		botsuka.antialiasing = false; //huli net to
		botsuka.screenCenter();
		botsuka.alpha = 0;
		add(botsuka);
		
		skiptext = new FlxText(5, FlxG.height-28, FlxG.width, "Hold Enter to skip...", 32);
		skiptext.setFormat("vcr.ttf", 32, FlxColor.WHITE, CENTER);
		add(skiptext);

		settTxt = new FlxText(0, 0, FlxG.width, "| RECOMMENDING TO CHECK SETTINGS FIRST BEFORE PLAYING |\n\n| РЕКОММЕНДУЮ ПОСЕТИТЬ НАСТРОЙКИ ПЕРЕД ИГРОЙ |", 48);
		settTxt.alpha = 0;
		settTxt.setFormat("mariones.ttf", 17, FlxColor.WHITE, CENTER);
		settTxt.screenCenter();
		add(settTxt);

		FlxTween.tween(disclaimer, {alpha: 1}, 1);

		FlxG.sound.play(Paths.sound('disclamer/warning'), 1, false, null, true, function() {
			FlxTween.tween(warnText, {alpha: 1}, 1);
			FlxG.sound.play(Paths.sound('disclamer/warnShaders'), 1, false, null, true, function() {

				FlxTween.tween(warnText, {alpha: 0}, 0.5, {
					onComplete: function(twn:FlxTween) {
						warnText.text = 'It also contains some slurs and bad words, it\'s recommended to play\nthis mod with headphones and censore some audios (A LOT) if you\nfamily friendly youtube content maker';
						FlxTween.tween(warnText, {alpha: 1}, 0.5);
					}
				});

				FlxG.sound.play(Paths.sound('disclamer/warnSlurs'), 1, false, null, true, function() {

					FlxTween.tween(warnText, {alpha: 0}, 0.5, {
						onComplete: function(twn:FlxTween) {
							warnText.text = 'Oh and of course it has Flashing Lights and other pain eye thingies\nIf you are sensitive to them then better disable it';
							FlxTween.tween(warnText, {alpha: 1}, 0.5);
						}
					});

					FlxG.sound.play(Paths.sound('disclamer/warnFlashin'), 1, false, null, true, function() {
						FlxTween.tween(disclaimer, {alpha: 0}, 1);
						FlxTween.tween(warnText, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween) {
								FlxTween.tween(botsuka, {alpha: 1}, 1);
							}
						});
						botPlay();
					});
				});
			});
		});
	}

	function goAwayBruh()
	{
		MusicBeatState.switchState(new CutState());
	}

	function botPlay()
	{
		FlxTween.tween(botsuka, {alpha: 1}, 1);
		FlxG.sound.play(Paths.sound('disclamer/bot'), 1, false, null, true, function() {
			FlxTween.tween(botsuka, {alpha: 0}, 1);
			FlxTween.tween(settTxt, {alpha: 1}, 2);
			FlxG.sound.play(Paths.sound('disclamer/end'), 1, false, null, true, function() {
				goAwayBruh();
			});
		});
	}

	override function update(elapsed:Float)
	{
		if((FlxG.keys.pressed.ESCAPE || FlxG.keys.pressed.ENTER)) 
		{
			proceed = Math.min(proceed + elapsed*60, proceedMax); // aka 1
			skiptext.alpha = proceed/100;
			if (proceed == proceedMax)
			{
				goAwayBruh();
			}
		} else {
			skiptext.alpha = 0;
			proceed = 0;
		}
		super.update(elapsed);
	}
}