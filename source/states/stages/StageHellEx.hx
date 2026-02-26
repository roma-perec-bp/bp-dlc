package states.stages;

import states.stages.objects.*;
import objects.Character;
import shaders.*;
import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;
import substates.GameOverSubstate;
import psychlua.LuaUtils;

import shaders.WiggleEffectRuntime;

class StageHellEx extends BaseStage
{
	var temp:FlxSprite;

	var bg:BGSprite;
	var bg_second:BGSprite;
	var fire:BGSprite;
	var wall:FlxSprite;

	var solidColBeh:FlxSprite;

	var vin:FlxSprite;

	var bigvin:FlxSprite;
	public var fireCool:Bool = false;
	var overlay:BGSprite;

	var rimDad = new DropShadowShader();
	var rimBf = new DropShadowShader();
	var rimBG = new DropShadowShader();

	var lolShader:BunnyShader = null;
	var noiseShader:NoiseShader = null;
	var bloomShader:BloomShader = null;

	var wiggleBack:WiggleEffectRuntime = null;
	var specialTrail:Bool = false;

	var effect:SMWPixelBlurShader;

	override function create()
	{
		var _song = PlayState.SONG;
		if(_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) GameOverSubstate.deathSoundName = 'fnf_loss_sfx-ex';
		if(_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) GameOverSubstate.loopSoundName = 'gameOver-ex';
		if(_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) GameOverSubstate.endSoundName = 'gameOverEnd-ex';
		if(_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) GameOverSubstate.characterName = 'bf_new-ex-dead';

		if (FlxG.random.bool(24))
		{
			if(_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) GameOverSubstate.deathSoundName = 'fnf_loss_sfx-ex-secret';
			if(_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) GameOverSubstate.characterName = 'bf_new-ex-dead-secret';
		}

		temp = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK); //needs for color shit LMAO
		temp.visible = false;
		//add(temp);


		var sky:BGSprite = new BGSprite('sky', -1419, -1517, 0.15, 0.7);
		sky.scale.set(1.4, 1.2);
		sky.updateHitbox();
		add(sky);

		var back:BGSprite = new BGSprite('back', -228, -221, 0.8, 0.8);
		back.updateHitbox();
		back.blend = ADD;
		add(back);

		wall = new FlxSprite(770, -942);
		wall.frames = Paths.getSparrowAtlas('red_wall_assets');
		wall.animation.addByPrefix('idle', "red_wall_default", 24, true);
		wall.animation.addByPrefix('appear', "red_wall_appear", 24, false);
		wall.animation.play('appear');
		wall.antialiasing = ClientPrefs.data.antialiasing;
		wall.alpha = 0.0001;
		wall.scrollFactor.set(0.6, 1);
		wall.updateHitbox();
		add(wall);

		//wall.offset.set(0, 0); //default
		//wall.offset.set(67, 9); //appear

		fire = new BGSprite('fire', -735, 1794, 0.9, 0.9, ['fire'], true); //-794
		fire.updateHitbox();
		add(fire);

		bg = new BGSprite('bg', -1047, -736, 1, 1);
		bg.updateHitbox();
		add(bg);

		var shadeBF = new BGSprite('shade_bg', 990, 751, 1, 1);
		shadeBF.updateHitbox();
		add(shadeBF);

		var shadeDAD = new BGSprite('shade_dad', -47, 672, 1, 1);
		shadeDAD.updateHitbox();
		add(shadeDAD);

		wiggleBack = new WiggleEffectRuntime(6, 4, 0.017, WiggleEffectType.DREAMY);

		bg_second = new BGSprite('secondBG_alt', -1047, -736, 0.8, 0.8);
		bg_second.visible = false;
		bg_second.scale.set(1.35, 1.35);
		bg_second.screenCenter();
		bg_second.updateHitbox();
		bg_second.shader = wiggleBack;
		add(bg_second);

		game.skipCountdown = true;
	}

	override function createPost()
    {
		overlay = new BGSprite('overlay', -1144, 18, 1, 1);
		overlay.updateHitbox();
		overlay.blend = ADD;
		overlay.alpha = 0.2;
		add(overlay);

		rimDad = new DropShadowShader();
		rimDad.setAdjustColor(-26, -21, 12, -26);
		rimDad.colorGay = 0xFFFF0000;
		rimDad.attachedSprite = dad;
		rimDad.distance = 10;
		rimDad.angle = 90;

		dad.animation.callback = function(anim, frame, index)
		{
			rimDad.updateFrameInfo(dad.frameWidth, dad.frameHeight, dad.frame.angle);
		};

		rimBf = new DropShadowShader();
		rimBf.setAdjustColor(-26, -21, 12, -26);
		rimBf.colorGay = 0xFFFF0000;
		rimBf.attachedSprite = boyfriend;
		rimBf.distance = 10;
		rimBf.angle = 90;

		boyfriend.animation.callback = function(anim, frame, index)
		{
			rimBf.updateFrameInfo(boyfriend.frameWidth, boyfriend.frameHeight, boyfriend.frame.angle);
		};

		rimBG = new DropShadowShader();
		rimBG.setAdjustColor(-26, -21, 12, -26);
		rimBG.colorGay = 0xFFFF0000;
		rimBG.attachedSprite = bg;
		rimBG.distance = 15;
		rimBG.angle = 90;

		rimBf.threshold = 6;
		rimDad.threshold = 6;
		rimBG.threshold = 6;

		dad.shader = rimDad;
		boyfriend.shader = rimBf;
		bg.shader = rimBG;

		if (!ClientPrefs.data.lowQuality)
		{
			if(ClientPrefs.data.flashing)
			{
				lolShader = new BunnyShader();
				noiseShader = new NoiseShader();
				bloomShader = new BloomShader();
				camGame.setFilters([new ShaderFilter(lolShader), new ShaderFilter(noiseShader)]);
			}

			if (!ClientPrefs.data.lowQuality){
				effect = new SMWPixelBlurShader();
			}
		}

		vin = new FlxSprite().loadGraphic(Paths.image('dark'));
		vin.updateHitbox();
		vin.setGraphicSize(FlxG.width, FlxG.height);
		vin.screenCenter();
		vin.cameras = [camOther];
		vin.alpha = 1;
		add(vin);

		bigvin = new FlxSprite().loadGraphic(Paths.image('big_vin'));
		bigvin.updateHitbox();
		bigvin.setGraphicSize(FlxG.width, FlxG.height);
		bigvin.screenCenter();
		bigvin.cameras = [camHudBehind];
		bigvin.alpha = 0.0001;
		add(bigvin);

		solidColBeh = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		solidColBeh.scale.set(5,5);
		solidColBeh.alpha = 0.001;
		addBehindGF(solidColBeh);

		camHUD.alpha = 0.0001;
	}

	override function update(elapsed:Float)
    {
		/*if(fireCool)
			if (game.health >= 0.4)
				game.health -= 0.001 * (elapsed/(1/60));*/

		if (lolShader != null) lolShader.data.iTime.value[0] += elapsed;
		if (noiseShader != null) noiseShader.data.iTime.value[0] += elapsed;
		if (wiggleBack != null) wiggleBack.update(elapsed);
	}

	override function eventPushed(event:objects.Note.EventNote)
	{
		switch(event.event)
		{
			//lol
		}
	}

	override function stepHit()
	{
		if(specialTrail && curStep % 2 == 0 && !ClientPrefs.data.lowQuality)
		{
			doGhostAnim();
		}
	}

	function doGhostAnim()
	{
		//if(onlyChart) return;
		var player:Character = dad;

		var ghost:Character = new Character(0, 0, player.curCharacter, player.isPlayer);

		ghost.flipX = player.flipX;
		ghost.debugMode = true;
	
		ghost.setPosition(player.x, player.y);
		ghost.animation.play(player.animation.curAnim.name, true, false, player.animation.curAnim.curFrame);

		ghost.scale.copyFrom(player.scale);
		ghost.updateHitbox();

		ghost.blend = LuaUtils.blendModeFromString('HARDLIGHT');

		ghost.scrollFactor.set(player.scrollFactor.x, player.scrollFactor.y);

		ghost.offset.set(player.offset.x, player.offset.y);

		ghost.alpha = player.alpha - 0.3;
		ghost.angle = player.angle;
		ghost.antialiasing = ClientPrefs.data.antialiasing ? !player.noAntialiasing : false;
		ghost.visible = true;

		ghost.color = FlxColor.fromRGB(player.healthColorArray[0] + 50, player.healthColorArray[1] + 50, player.healthColorArray[2] + 50);

		ghost.velocity.y = FlxG.random.int(-300, 300);
		ghost.velocity.x = FlxG.random.int(-300, 300);

		insert(members.indexOf(dadGroup), ghost);
	
		FlxTween.tween(ghost, {alpha: 0}, Conductor.crochet * 0.002, {
			ease: FlxEase.linear,
				onComplete: function(twn:FlxTween)
				{
					ghost.destroy();
					ghost.kill();
					remove(ghost, true);
				}
		});
	}

	override function eventCalled(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, flValue1:Null<Float>, flValue2:Null<Float>, flValue3:Null<Float>, flValue4:Null<Float>, flValue5:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'Exerection Triggers':
				switch(value1)
				{
					case 'remove 1bit shader':
						if (!ClientPrefs.data.lowQuality)
						{
							if(ClientPrefs.data.flashing)
							{
								lolShader = new BunnyShader();
								noiseShader = new NoiseShader();
								camGame.setFilters([new ShaderFilter(bloomShader)]);
							}
						}
						FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.linear});

					case 'default colors':
						rimDad.setAdjustColor(-26, -21, 12, -26);
						rimDad.colorGay = 0xFFFF0000;
						rimDad.distance = 15;
						rimDad.threshold = 6;

						rimBf.setAdjustColor(-26, -21, 12, -26);
						rimBf.colorGay = 0xFFFF0000;
						rimBf.distance = 15;
						rimBf.threshold = 6;

						rimBG.setAdjustColor(-26, -21, 12, -26);
						rimBG.colorGay = 0xFFFF0000;
						rimBG.distance = 20;
						rimBG.threshold = 6;

					case 'fire off':
						rimDad.setAdjustColor(-42, -21, 12, -33);
						rimDad.colorGay = 0xFFFF0000;
						rimDad.distance = 15;

						rimBf.setAdjustColor(-42, -21, 12, -33);
						rimBf.colorGay = 0xFFFF0000;
						rimBf.distance = 15;

						rimBG.setAdjustColor(-42, -21, 12, -33);
						rimBG.colorGay = 0xFFFF0000;
						rimBG.distance = 20;

						rimBG.threshold = 0.1;
						rimBf.threshold = 0.1;
						rimDad.threshold = 0.1;

						fire.y = 1794;

						boyfriend.color = 0xFFFFFFFF;
						dad.color = 0xFFFFFFFF;
						bg.color = 0xFFFFFFFF;

						fireCool = false;

					case 'fire colors':
						rimDad.setAdjustColor(-29, -13, 34, -31);
						rimDad.colorGay = 0xFFFFFFCC;
						rimDad.distance = 15;

						rimBf.setAdjustColor(-29, -13, 34, -31);
						rimBf.colorGay = 0xFFFFFFCC;
						rimBf.distance = 15;

						rimBG.setAdjustColor(-29, -13, 34, -31);
						rimBG.colorGay = 0xFFFFFFCC;
						rimBG.distance = 20;

						rimBG.threshold = 0.1;
						rimBf.threshold = 0.1;
						rimDad.threshold = 0.1;

					case 'red transition':
						wall.alpha = 1;
						wall.animation.play('appear');
						wall.offset.set(67, 9);

						wall.animation.finishCallback = function(pog:String)
						{
							if (wall.animation.name == 'appear')
							{
								wall.animation.play('idle');
								wall.offset.set(0, 0);
							}
						}

						FlxTween.num(6, 0.1, 1, {ease: FlxEase.expoOut}, function(thr:Float) 
							{ 
							  rimBf.threshold = thr;
							  rimBG.threshold = thr;
							  rimDad.threshold = thr;
							});

						FlxTween.num(-26, -33, 1, {ease: FlxEase.expoOut}, function(sat:Float) 
							{ 
							  rimBf.baseSaturation = sat;
							  rimBG.baseSaturation = sat;
							  rimDad.baseSaturation = sat;
							});

						FlxTween.num(12, 12, 1, {ease: FlxEase.expoOut}, function(contrast:Float) 
							{ 
							  rimBf.baseContrast = contrast;
							  rimBG.baseContrast = contrast;
							  rimDad.baseContrast = contrast;
							});

						FlxTween.num(-21, -21, 1, {ease: FlxEase.expoOut}, function(hue:Float) 
							{ 
							  rimBf.baseHue = hue;
							  rimBG.baseHue = hue;
							  rimDad.baseHue = hue;
							});

						FlxTween.num(-26, -42, 1, {ease: FlxEase.expoOut}, function(brght:Float) 
							{ 
							  rimBf.baseBrightness = brght;
							  rimBG.baseBrightness = brght;
							  rimDad.baseBrightness = brght;
							});

					case 'fire transition':
						fireCool = true;
						FlxTween.tween(fire, {y: -794}, 1, {ease: FlxEase.expoOut});

						/*FlxTween.color(boyfriend, 2, 0xFFFFFFFF, 0xFFff7b43, {ease: FlxEase.expoOut});
						FlxTween.color(dad, 2, 0xFFFFFFFF, 0xFFff7b43, {ease: FlxEase.expoOut});
						FlxTween.color(bg, 2, 0xFFFFFFFF, 0xFFff7b43, {ease: FlxEase.expoOut});*/


						FlxTween.color(temp, 2, 0xFFFF0000, 0xFFFFFFCC, {ease: FlxEase.expoOut, onUpdate: (t)->{ 
							  rimBf.colorGay = temp.color;
							  rimBG.colorGay = temp.color;
							  rimDad.colorGay = temp.color;
							}});

						FlxTween.num(-26, -31, 2, {ease: FlxEase.expoOut}, function(sat:Float) 
							{ 
							  rimBf.baseSaturation = sat;
							  rimBG.baseSaturation = sat;
							  rimDad.baseSaturation = sat;
							});

						FlxTween.num(12, 34, 2, {ease: FlxEase.expoOut}, function(contrast:Float) 
							{ 
							  rimBf.baseContrast = contrast;
							  rimBG.baseContrast = contrast;
							  rimDad.baseContrast = contrast;
							});

						FlxTween.num(-21, -13, 2, {ease: FlxEase.expoOut}, function(hue:Float) 
							{ 
							  rimBf.baseHue = hue;
							  rimBG.baseHue = hue;
							  rimDad.baseHue = hue;
							});

						FlxTween.num(-42, -29, 2, {ease: FlxEase.expoOut}, function(brght:Float) 
							{ 
							  rimBf.baseBrightness = brght;
							  rimBG.baseBrightness = brght;
							  rimDad.baseBrightness = brght;
							});

					case 'fire go':
						FlxTween.tween(fire, {y: 1794}, 2, {ease: FlxEase.expoIn});

						FlxTween.color(temp, 2, 0xFFFFFFCC, 0xFFFF0000, {ease: FlxEase.expoOut, onUpdate: (t)->{ 
							rimBf.colorGay = temp.color;
							rimBG.colorGay = temp.color;
							rimDad.colorGay = temp.color;
						  }});

						FlxTween.num(-33, -26, 1, {ease: FlxEase.expoOut}, function(sat:Float) 
							{ 
							  rimBf.baseSaturation = sat;
							  rimBG.baseSaturation = sat;
							  rimDad.baseSaturation = sat;
							});

						FlxTween.num(12, 12, 1, {ease: FlxEase.expoOut}, function(contrast:Float) 
							{ 
							  rimBf.baseContrast = contrast;
							  rimBG.baseContrast = contrast;
							  rimDad.baseContrast = contrast;
							});

						FlxTween.num(-21, -21, 1, {ease: FlxEase.expoOut}, function(hue:Float) 
							{ 
							  rimBf.baseHue = hue;
							  rimBG.baseHue = hue;
							  rimDad.baseHue = hue;
							});

						FlxTween.num(-42, -26, 1, {ease: FlxEase.expoOut}, function(brght:Float) 
							{ 
							  rimBf.baseBrightness = brght;
							  rimBG.baseBrightness = brght;
							  rimDad.baseBrightness = brght;
							});

					case 'fire colors second':
						dad.shader = rimDad;

						rimDad.setAdjustColor(-29, -13, 34, -31);
						rimDad.colorGay = 0xFFFFFFCC;
						rimDad.distance = 15;

						rimBf.setAdjustColor(-29, -13, 34, -31);
						rimBf.colorGay = 0xFFFFFFCC;
						rimBf.distance = 15;

						rimBG.setAdjustColor(-29, -13, 34, -31);
						rimBG.colorGay = 0xFFFFFFCC;
						rimBG.distance = 20;

						rimBG.threshold = 0.1;
						rimBf.threshold = 0.1;
						rimDad.threshold = 0.1;

					case 'big vignette':
						bigvin.alpha = 1;

					case 'no big vignette':
						bigvin.alpha = 0.0001;

					case 'pixel blur':
						if (!ClientPrefs.data.lowQuality){
							camGame.setFilters([new ShaderFilter(bloomShader), new ShaderFilter(effect.shader)]);
							//effect.setStrength(40, 40);
							FlxTween.num(0, 20, Conductor.stepCrochet * 32 / 1000, function(v)
							{
								effect.setStrength(v, v);
							});
					}

					case 'pixel blur no':
						if (!ClientPrefs.data.lowQuality)
							camGame.setFilters([new ShaderFilter(bloomShader)]);

					case 'second stage':
						specialTrail = true;
						bg_second.visible = true;
						game.boyfriend.alpha = 0;

						GameOverSubstate.deathSoundName = 'fnf_loss_sfx-ex';
						GameOverSubstate.characterName = 'bf-dead-front';

					case 'black bg':
						FlxTween.tween(solidColBeh, {alpha: flValue2}, Conductor.stepCrochet * flValue3 / 1000);

					case 'get back to normal':
						GameOverSubstate.deathSoundName = 'fnf_loss_sfx-ex';
						GameOverSubstate.characterName = 'bf_new-ex-dead';
					
						specialTrail = false;
						bg_second.visible = false;
						game.boyfriend.alpha = 1;

						rimDad.setAdjustColor(-26, -21, 12, -26);
						rimDad.colorGay = 0xFFFF0000;
						rimDad.distance = 15;
						rimDad.threshold = 6;

						rimBf.setAdjustColor(-26, -21, 12, -26);
						rimBf.colorGay = 0xFFFF0000;
						rimBf.distance = 15;
						rimBf.threshold = 6;

						rimBG.setAdjustColor(-26, -21, 12, -26);
						rimBG.colorGay = 0xFFFF0000;
						rimBG.distance = 20;
						rimBG.threshold = 6;

						wall.alpha = 0;
						dad.shader = rimDad;
				}
		}
	}
}