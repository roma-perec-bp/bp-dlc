package states.stages;

import states.stages.objects.*;
import shaders.*;
import funkin.vis.dsp.SpectralAnalyzer;

import flixel.effects.particles.FlxEmitter.FlxEmitterMode;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;

import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;

import flixel.addons.text.FlxTypeText;
import psychlua.LuaUtils;

import substates.GameOverSubstate;

import objects.Note;

import objects.Character;

class StageFinal extends BaseStage
{
	var bg:BGSprite;
	var overlay:BGSprite;
	var light:BGSprite;

	var flashbacc:FlxSprite;

	var bloomShader:UhShader = null;
	var desaturate:DesaturateShader = null;

	var blackOverlay:FlxSprite;

	public var caShader:ChromaticWarp = null;

	final VIZ_MAX = 11; //ranges from viz1 to viz11
	final VIZ_POS_X:Array<Float> = [ -540,   -370,  -210,  -30,   120,  280,   420, 550, 680, 800, 920];
	final VIZ_POS_Y:Array<Float> = [  350,    290,   250,  220,   210,  210,   210, 220, 250, 290, 350];
	public var vizSprites:Array<FlxSprite> = [];

	var analyzer:SpectralAnalyzer;
	var volumes:Array<Float> = [];

	public var lavaEmitter:FlxTypedEmitter<LavaParticle>;

	var amdAlert:Bool = false;


	//FIRST DIALOGUE SHIR
	var curDil:Int = 0;
	var dialogueIntro:Array<String> = [
		'*Долгий коварный смех*',
		'Отличная работа! Ты всех их прошел!',
		'Но мы еще не закончили... Остался последний экзамен!',
		'Ты сражался против моих существ и созданий...',
		'Но сможешь ли ты одолеть...',
		'МЕНЯ'
	];

	var dialogueEnd:Array<String> = [
		'*Коварный долгий смех*',
		'Ох да! Ладно паренёк ты и вправду хорош в своем деле!',
		'Я думаю у тебя есть даже больше шансов стать чертом, и заниматься лучшей работой!\nМУЧИТЬ ВСЕХ ГРЕШНИКОВ ЭТОГО МИРА',
		'Главное когда ты умрешь нужно чтоб ты стал зомби и чтоб ты был еще перцем.',
		'На конус похуй, главное чтоб перцем был.',
		'И тогда думаю ты будешь нанят в будущем!',
		'Я верю что у тебя всё получиться!',
		'А пока ты жив, еби мозги другим! Я буду наблюдать снизу...',
		'Ещё увидимся...'
	];

	public var devilTalk:FlxSound;

	var curDialEpis:Int = 0;
	var flush:Int = 0;

	var swagDialogue:FlxTypeText;
	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	public var snd(default, set):FlxSound;
	function set_snd(changed:FlxSound)
	{
		snd = changed;
		initAnalyzer();
		return snd;
	}

	override function create()
	{
		GameOverSubstate.deathSoundName = 'fnf_loss_sfx-final';
		GameOverSubstate.characterName = 'bf-dead-front';
		GameOverSubstate.loopSoundName = 'gameOver-ex';
		GameOverSubstate.endSoundName = 'gameOverEnd-ex';

		var appGL = lime.app.Application.current.window.context.gl;
		if(appGL.getString(appGL.VENDOR).contains('AMD') || appGL.getString(appGL.VENDOR).contains('ATI') || appGL.getString(appGL.SHADING_LANGUAGE_VERSION).substr(0, 3) < '1.2')
			amdAlert = true;

		if(!ClientPrefs.data.optimize)
		{
			if (!ClientPrefs.data.lowQuality)
			{
				var vizX:Float = 0;
				var vizY:Float = 0;
				for (i in 1...VIZ_MAX+1)
				{
					volumes.push(0.0);
					vizX = VIZ_POS_X[i-1];
					vizY = VIZ_POS_Y[i-1];
					var viz:FlxSprite = new FlxSprite(vizX, vizY);
					viz.frames = Paths.getSparrowAtlas('vis_spr/vis_'+i);
					viz.animation.addByPrefix('VIZ', Std.string(i), 0);
					viz.animation.play('VIZ', true);
					viz.animation.curAnim.finish(); //make it go to the lowest point
					viz.antialiasing = ClientPrefs.data.antialiasing;
					vizSprites.push(viz);
					viz.updateHitbox();
					viz.centerOffsets();
					add(viz);
					viz.alpha = 0.0001;
				}
			}
		
			bg = new BGSprite('defeat_floor_lmao', -800, 460, 1, 1);
			bg.updateHitbox();
			bg.alpha = 0.0001;
			add(bg);
		}

		swagDialogue = new FlxTypeText(0, 520, Std.int(FlxG.width * 0.6), "", 42);
		swagDialogue.font = Paths.font("HouseofTerrorRus.ttf");
		swagDialogue.alignment = CENTER;
		swagDialogue.color = 0xFFFF0000;
		swagDialogue.cameras = [camOther];
		swagDialogue.screenCenter(X);
		//swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.4)];
		add(swagDialogue);

		camHUD.alpha = 0.0001;

		if (isStoryMode)
		{
			if (!seenCutscene)
				setStartCallback(intro);
			else
				game.skipCountdown = true;

			setEndCallback(ending);
		}
		else
			game.skipCountdown = true;
	}

	function ending()
	{
		game.endingSong = true;
		inCutscene = true;
		canPause = false;
		dialogueOpened = true;
		dialogueStarted = true;
		inCutscene = true;
		curDialEpis = 2;
		FlxG.sound.playMusic(Paths.music('devil_song'), 1);
		startDialogue(dialogueEnd);
	}

	function intro()
	{
		game.canPause = false;
		dialogueOpened = true;
		dialogueStarted = true;
		inCutscene = true;
		curDialEpis = 1;
		FlxG.sound.playMusic(Paths.music('devil_song'), 1);
		startDialogue(dialogueIntro);
	}

	override function startSong()
	{
		snd = FlxG.sound.music;
		game.canPause = true;

		curDil = 0;
		FlxTween.tween(camHUD, {alpha: 1}, 6, {ease: FlxEase.linear});
		game.tweenCameraZoom(0.6, 3, false, FlxEase.quadInOut);

		var warning:FlxSprite = new FlxSprite();

		if(game.hard)
			warning.loadGraphic(Paths.image('text_hard'));
		else
			warning.loadGraphic(Paths.image('text_normal'));

		warning.scale.set(0.6, 0.6);
		warning.updateHitbox();
		warning.screenCenter();
		add(warning);
		warning.alpha = 0.0001;
		warning.cameras = [camOther];

		FlxTween.tween(warning, {alpha: 1}, 3, {onComplete:
			function(twn:FlxTween) {
				FlxTween.tween(warning, {alpha: 0}, 1, {startDelay: 3, onComplete:
					function(twn:FlxTween) {
						remove(warning);
						warning.destroy();
					}
				});
			}
		});
	}

	override function noteMiss(note:Note) 
	{
		if(ClientPrefs.data.optimize) return;

		blackOverlay.alpha = 0.6;
		if (!ClientPrefs.data.lowQuality && ClientPrefs.data.shaders)
		{
			if (ClientPrefs.data.flashing) caShader.warpStrength = 16;
		}

		if(ClientPrefs.data.camZooms) {
			game.cameraBopMultiplier += 0.1;
			camHUD.zoom += 0.1;
		}
	}

	var levels:Array<Bar>;
	var levelMax:Int = 0;

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if(Controls.instance.justPressed('accept'))
		{
			if(dialogueOpened)
			{
				if(dialogueEnded)
				{
					if(game.endingSong)
					{
						var dialogueList:Array<String>;
						dialogueList = dialogueEnd;
						if (dialogueList[1] == null && dialogueList[0] != null)
						{
							camOther.fade(FlxColor.BLACK, 1, false);
							dialogueOpened = false;
							FlxG.sound.music.fadeOut(1);
						
							new FlxTimer().start(3, function(timer:FlxTimer)
							{
								var tag:String = LuaUtils.formatVariable('voices_devil');
								var variables = MusicBeatState.getVariables();
								var snd:FlxSound = variables.get(tag);
								if(snd != null)
								{
									snd.stop();
									variables.remove(tag);
								}

								FlxG.sound.music.stop();
								FlxG.sound.music.pitch = 1;

								new FlxTimer().start(0.01, function(timer:FlxTimer)
								{	
									MusicBeatState.switchState(new EndDialogueState());
								});
						});
						}
						else
						{
							dialogueList.remove(dialogueList[0]);
							startDialogue(dialogueList);
						}
					}
					else
					{
						var dialogueList:Array<String>;
						dialogueList = dialogueIntro;
						if (dialogueList[1] == null && dialogueList[0] != null)
						{
							dialogueOpened = false;
							game.skipCountdown = true;
							startCountdown();
							swagDialogue.alpha = 0;
						}
						else
						{
							dialogueList.remove(dialogueList[0]);
							startDialogue(dialogueList);
						}
					}
				}
				else if (dialogueStarted)
				{
					swagDialogue.skip();
				}
			}
		}

		if(!game.endingSong && !game.startingSong)
		{
			if(ClientPrefs.data.optimize) return;

			blackOverlay.alpha = FlxMath.lerp(0, blackOverlay.alpha, 0.95);
			/*FlxG.sound.music.volume = FlxMath.lerp(1, FlxG.sound.music.volume, 0.95);
			game.vocals.volume = FlxMath.lerp(1, game.vocals.volume, 0.95);
			game.opponentVocals.volume = FlxMath.lerp(1, game.opponentVocals.volume, 0.95);*/
		}

		if (!ClientPrefs.data.lowQuality)
		{
			if(ClientPrefs.data.optimize) return;

			if (ClientPrefs.data.flashing && ClientPrefs.data.shaders) caShader.warpStrength = FlxMath.lerp(0, caShader.warpStrength, 0.95);

			if(analyzer == null) return;

			levels = analyzer.getLevels(levels);
			var oldLevelMax = levelMax;
			levelMax = 0;
			for (i in 0...Std.int(Math.min(vizSprites.length, levels.length)))
			{
				var animFrame:Int = Math.round(levels[i].value * 23);
				animFrame = Std.int(Math.abs(FlxMath.bound(animFrame, 0, 23) - 23)); // shitty dumbass flip, cuz dave got da shit backwards lol!
			
				vizSprites[i].animation.curAnim.curFrame = animFrame;
				levelMax = Std.int(Math.max(levelMax, 23 - animFrame));
			}
		}
	}

	public function initAnalyzer()
	{
		@:privateAccess
		analyzer = new SpectralAnalyzer(snd._channel.__audioSource, 11, 0.1, 40);
	
		#if desktop
		// On desktop it uses FFT stuff that isn't as optimized as the direct browser stuff we use on HTML5
		// So we want to manually change it!
		analyzer.fftN = 256;
		#end
	}

	function startDialogue(dialogueList:Array<String>):Void
	{
		/*var variables = MusicBeatState.getVariables();
		var snd:FlxSound = variables.get(LuaUtils.formatVariable('voices'));
		if(snd != null)
		{
			snd.stop();
			variables.remove(LuaUtils.formatVariable('voices'););
		}*/

		var variables = MusicBeatState.getVariables();
		var tag:String = LuaUtils.formatVariable('voices_devil');
		var oldSnd = variables.get(tag);
		if(oldSnd != null)
		{
			oldSnd.stop();
			oldSnd.destroy();
		}
	
		if(game.endingSong)
		{
			variables.set(tag, FlxG.sound.play(Paths.sound('devil_quest/end/'+curDil), 1, false, null, true, function()
				{
					variables.remove(tag);
				}));

			curDil++;
		}
		else
		{
			if(curDil == 5)
			{
				FlxG.sound.music.stop();
				dialogueOpened = false;
				FlxTween.tween(swagDialogue, {alpha: 0}, 3, {startDelay: 1});
			}

			variables.set(tag, FlxG.sound.play(Paths.sound('devil_quest/song/'+curDil), 1, false, null, true, function()
				{
					variables.remove(tag);

					if(curDil == 5)
					{
						//FlxG.sound.music.stop();
						dialogueOpened = false;
						game.skipCountdown = true;
						startCountdown();
					}
				}));

				if(curDil != 5) curDil++;
		}

		swagDialogue.alpha = 1;
		swagDialogue.resetText(dialogueList[0]);

		swagDialogue.start(0.06, true);
		swagDialogue.completeCallback = function() {
			dialogueEnded = true;
		};
	
		dialogueEnded = false;
	}

	override function createPost()
    {
		if (!ClientPrefs.data.lowQuality)
		{
			if(ClientPrefs.data.optimize) return;

			overlay = new BGSprite('red_shit', -650, -100, 1, 1);
			overlay.alpha = 0.0001;
			overlay.updateHitbox();
			overlay.blend = ADD;
			add(overlay);

			light = new BGSprite('light_dev', -650, -900, 1, 1);
			light.alpha = 0.0001;
			light.updateHitbox();
			light.blend = ADD;
			add(light);

			light.setPosition(dad.getGraphicMidpoint().x - light.width / 2, -400);

			lavaEmitter = new FlxTypedEmitter<LavaParticle>(dad.getGraphicMidpoint().x - light.width / 2, 3400);
			lavaEmitter.particleClass = LavaParticle;
			lavaEmitter.launchMode = FlxEmitterMode.SQUARE;
			lavaEmitter.width = FlxG.width;
			lavaEmitter.velocity.set(0, -150, 0, -300, 0, -10, 0, -50);
			lavaEmitter.alpha.set(1, 0);
			add(lavaEmitter);
			lavaEmitter.start(false);
		}

		if (!ClientPrefs.data.lowQuality && ClientPrefs.data.shaders)
		{
			if(ClientPrefs.data.optimize) return;

			if(ClientPrefs.data.flashing)
			{
				bloomShader = new UhShader();

				caShader = new ChromaticWarp();
				caShader.warpStrength = 0;
				camGame.setFilters([new ShaderFilter(caShader)]);
			}
		}
		
		if(!ClientPrefs.data.optimize)
		{
			desaturate = new DesaturateShader();

			blackOverlay = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			blackOverlay.scale.set(5,5);
			blackOverlay.alpha = 0.001;
			add(blackOverlay);
	
			flashbacc = new FlxSprite().loadGraphic(Paths.image('flashback/flash_0'));
			flashbacc.scale.set(0.6, 0.6);
			flashbacc.updateHitbox();
			flashbacc.screenCenter();
			add(flashbacc);
			flashbacc.alpha = 0.0001;
			flashbacc.cameras = [camHudBehind];
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, flValue1:Null<Float>, flValue2:Null<Float>, flValue3:Null<Float>, flValue4:Null<Float>, flValue5:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Final Triggers':
				switch(value1)
				{
					case 'appear':
						if(ClientPrefs.data.optimize) return;

						if (!ClientPrefs.data.lowQuality)
						{
							if(ClientPrefs.data.flashing && ClientPrefs.data.shaders)
							{
								if(amdAlert)
									camGame.setFilters([new ShaderFilter(caShader)]);
								else
									camGame.setFilters([new ShaderFilter(bloomShader), new ShaderFilter(caShader)]);
							}
							else
							{
								camGame.setFilters([]);
							}

							for (i in 0...Std.int(Math.min(vizSprites.length, levels.length)))
							{
								vizSprites[i].alpha = 1;
							}
							overlay.alpha = 0.4;
						}
						bg.alpha = 1;

					case 'no bg':
						if(ClientPrefs.data.optimize) return;

						bg.alpha = 1;
						if (!ClientPrefs.data.lowQuality)
						{
							if(ClientPrefs.data.flashing && ClientPrefs.data.shaders)
							{
								if(amdAlert)
									camGame.setFilters([new ShaderFilter(caShader)]);
								else
									camGame.setFilters([new ShaderFilter(bloomShader), new ShaderFilter(caShader)]);
							}
							else
							{
								camGame.setFilters([]);
							}
						}
						else
							camGame.setFilters([]);

					case 'trans':
						if(ClientPrefs.data.optimize) return;

						bg.alpha = 1;
						if (!ClientPrefs.data.lowQuality)
						{
							if(ClientPrefs.data.flashing && ClientPrefs.data.shaders)
							{
								if(amdAlert)
									camGame.setFilters([new ShaderFilter(desaturate), new ShaderFilter(caShader)]);
								else
									camGame.setFilters([new ShaderFilter(bloomShader), new ShaderFilter(desaturate), new ShaderFilter(caShader)]);
							}
							else
							{
								camGame.setFilters([new ShaderFilter(desaturate)]);
							}

							for (i in 0...Std.int(Math.min(vizSprites.length, levels.length)))
							{
								vizSprites[i].alpha = 0.0001;
							}
							overlay.alpha = 0.00001;
						}
						else
						{
							camGame.setFilters([new ShaderFilter(desaturate)]);
						}

					case 'end':
						if(!ClientPrefs.data.optimize)
						{
							camGame.setFilters([]);
							camGame.stopFX();
							camHUD.stopFX();
							bg.alpha = 0.0001;
							if (!ClientPrefs.data.lowQuality)
							{
	
								for (i in 0...Std.int(Math.min(vizSprites.length, levels.length)))
								{
									vizSprites[i].alpha = 0.0001;
								}
								overlay.alpha = 0.0001;
							}
	
							if(!ClientPrefs.data.lowQuality)  light.alpha = 0.0001;
							if(!ClientPrefs.data.lowQuality) FlxTween.tween(lavaEmitter, {y: 3400}, 0.0001, {ease: FlxEase.expoOut});
						}

						FlxTween.tween(camHUD, {alpha: 0}, 3, {ease: FlxEase.linear});
					case 'flash appear':
						if(ClientPrefs.data.optimize) return;

						flashbacc.alpha = 1;
						camHudBehind.zoom = 2;
						FlxTween.tween(camHudBehind, {zoom: 1}, Conductor.stepCrochet * 64 / 1000, {ease: FlxEase.smootherStepOut});

					case 'flash do':
						if(ClientPrefs.data.optimize) return;
						
						flush++;
						flashbacc.loadGraphic(Paths.image('flashback/flash_'+flush));

					case 'flash bye':
						if(ClientPrefs.data.optimize) return;

						flashbacc.alpha = 0.0001;

					case 'brutal pizdec':
						if(ClientPrefs.data.optimize) return;

						if(!ClientPrefs.data.lowQuality)  light.alpha = 0.45;
						if(!ClientPrefs.data.lowQuality) FlxTween.tween(lavaEmitter, {y: 800}, 1, {ease: FlxEase.expoOut});
				}
		}
	}
}