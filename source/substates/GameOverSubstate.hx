package substates;

import backend.WeekData;

import objects.Character;
import flixel.FlxObject;
import flixel.FlxSubState;

import flixel.FlxCamera;

import flixel.util.FlxAxes;
import flixel.math.FlxPoint;

import states.MainMenuState;
import states.AdState;

import openfl.filters.ShaderFilter;
import openfl.filters.BlurFilter;

import shaders.VCRMario85;
import shaders.ShadersHandler;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Character;
	var camFollow:FlxObject;

	var stagePostfix:String = "";

	var fuckbeat:Bool = false;

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	public static var deathDelay:Float = 0;

	var blackBarThingie:FlxSprite;
	var tvTransition:FlxSprite;

	public var vcr:VCRMario85;

	public static var instance:GameOverSubstate;
	public function new(?playStateBoyfriend:Character = null)
	{
		if(playStateBoyfriend != null && playStateBoyfriend.curCharacter == characterName) //Avoids spawning a second boyfriend cuz animate atlas is laggy
		{
			this.boyfriend = playStateBoyfriend;
		}
		super();
	}

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		deathDelay = 0;

		var _song = PlayState.SONG;
		if(_song != null)
		{
			if(_song.gameOverChar != null && _song.gameOverChar.trim().length > 0) characterName = _song.gameOverChar;
			if(_song.gameOverSound != null && _song.gameOverSound.trim().length > 0) deathSoundName = _song.gameOverSound;
			if(_song.gameOverLoop != null && _song.gameOverLoop.trim().length > 0) loopSoundName = _song.gameOverLoop;
			if(_song.gameOverEnd != null && _song.gameOverEnd.trim().length > 0) endSoundName = _song.gameOverEnd;
		}
	}

	var charX:Float = 0;
	var charY:Float = 0;

	var overlay:FlxSprite;
	var overlayConfirmOffsets:FlxPoint = FlxPoint.get();

	public var camHUD:FlxCamera;
	override function create()
	{
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		instance = this;

		Conductor.songPosition = 0;

		if(PlayState.SONG.song == 'UNFUCKABLE')
		{
			deathSoundName = 'UBdeath';
			loopSoundName = 'UBloop';
			endSoundName = 'UBconfirm';

			if(Init.fun >= 43 && Init.fun <= 52)
				loopSoundName = 'static';

			camHUD.shake(0.05, 0.5);
			
			Conductor.bpm = 108;

			camHUD.zoom = 1;

			var pibeYCBU = new BGSprite('gameover/YCBU_GameOver_Assets', ['color screen'], true);
			pibeYCBU.screenCenter();
			//pibeYCBU.y += 100;
			pibeYCBU.cameras = [camHUD];
			add(pibeYCBU);

			var pibeYCB2 = new BGSprite('gameover/YCBU_GameOver_Assets', ['text'], true);
			pibeYCB2.screenCenter();
			//pibeYCB2.x -= 75;
			//pibeYCB2.y += 430;
			pibeYCB2.x -= 75;
			pibeYCB2.y += 330;
			pibeYCB2.cameras = [camHUD];
			add(pibeYCB2);
			
			blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
			blackBarThingie.visible = false;
			blackBarThingie.cameras = [camHUD];
			add(blackBarThingie);

			tvTransition = new BGSprite('gameover/tv_trans', 0, 0, ['transition'], false);
			tvTransition.animation.addByPrefix('dothething', 'transition', 24, false);
			tvTransition.antialiasing = ClientPrefs.data.antialiasing;
			tvTransition.screenCenter();
			tvTransition.visible = false;
			//tvTransition.x += 35;
			//tvTransition.y += 110;
			tvTransition.cameras = [camHUD];
			add(tvTransition);

			if(Init.fun >= 43 && Init.fun <= 52)
			{
				FlxG.sound.music.loadEmbedded(Paths.music(loopSoundName), true);

				new FlxTimer().start(FlxG.random.float(10, 42), function(tmr:FlxTimer)
				{
					FlxG.sound.play(Paths.soundEmbed('secretMorse'));
				});
			}
			else
			{
				new FlxTimer().start(4.44, function(tmr:FlxTimer)
				{
						fuckbeat = true;
				});
				
				FlxG.sound.music.loadEmbedded(Paths.music('UBstart'), true, function()
					{
						FlxG.sound.music.loadEmbedded(Paths.music(loopSoundName), true);
					}	
				);
			}
			FlxG.sound.music.play(true);
		}
		else
		{
			if(boyfriend == null)
			{
				boyfriend = new Character(PlayState.instance.boyfriend.getScreenPosition().x, PlayState.instance.boyfriend.getScreenPosition().y, characterName, true);
				boyfriend.x += boyfriend.positionArray[0] - PlayState.instance.boyfriend.positionArray[0];
				boyfriend.y += boyfriend.positionArray[1] - PlayState.instance.boyfriend.positionArray[1];
			}
			boyfriend.skipDance = true;
			add(boyfriend);

			FlxG.camera.scroll.set();
			FlxG.camera.target = null;

			boyfriend.playAnim('firstDeath');

			camFollow = new FlxObject(0, 0, 1, 1);
			camFollow.setPosition(boyfriend.getGraphicMidpoint().x + boyfriend.cameraPosition[0], boyfriend.getGraphicMidpoint().y + boyfriend.cameraPosition[1]);
			FlxG.camera.focusOn(new FlxPoint(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2)));
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
			add(camFollow);
		}

		FlxG.sound.play(Paths.sound(deathSoundName));
		
		PlayState.instance.setOnScripts('inGameOver', true);
		PlayState.instance.callOnScripts('onGameOverStart', []);

		if(PlayState.SONG.song != 'UNFUCKABLE')
		{
			FlxG.sound.music.loadEmbedded(Paths.music(loopSoundName), true);
		}

		if(characterName == 'pico-dead')
		{
			overlay = new FlxSprite(boyfriend.x + 205, boyfriend.y - 80);
			overlay.frames = Paths.getSparrowAtlas('Pico_Death_Retry');
			overlay.animation.addByPrefix('deathLoop', 'Retry Text Loop', 24, true);
			overlay.animation.addByPrefix('deathConfirm', 'Retry Text Confirm', 24, false);
			overlay.antialiasing = ClientPrefs.data.antialiasing;
			overlayConfirmOffsets.set(250, 200);
			overlay.visible = false;
			add(overlay);

			boyfriend.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
			{
				switch(name)
				{
					case 'firstDeath':
						if(frameNumber >= 36 - 1)
						{
							overlay.visible = true;
							overlay.animation.play('deathLoop');
							boyfriend.animation.callback = null;
						}
					default:
						boyfriend.animation.callback = null;
				}
			}

			if(PlayState.instance.gf != null && PlayState.instance.gf.curCharacter == 'nene')
			{
				var neneKnife:FlxSprite = new FlxSprite(boyfriend.x - 450, boyfriend.y - 250);
				neneKnife.frames = Paths.getSparrowAtlas('NeneKnifeToss');
				neneKnife.animation.addByPrefix('anim', 'knife toss', 24, false);
				neneKnife.antialiasing = ClientPrefs.data.antialiasing;
				neneKnife.animation.finishCallback = function(_)
				{
					remove(neneKnife);
					neneKnife.destroy();
				}
				insert(0, neneKnife);
				neneKnife.animation.play('anim', true);
			}
		}

		super.create();

		if(PlayState.SONG.song == 'UNFUCKABLE' && ClientPrefs.data.tvEffect)
		{
			vcr = new VCRMario85();

			FlxG.camera.setFilters([new ShaderFilter(vcr)]);
			camHUD.setFilters([new ShaderFilter(vcr)]);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(PlayState.SONG.song == 'UNFUCKABLE' && ClientPrefs.data.tvEffect)
		{
			vcr.update(elapsed);
		}

		//PlayState.instance.callOnScripts('onUpdate', [elapsed]);

		var justPlayedLoop:Bool = false;
		if(PlayState.SONG.song != 'UNFUCKABLE')
		{
			if (!boyfriend.isAnimationNull() && boyfriend.getAnimationName() == 'firstDeath' && boyfriend.isAnimationFinished())
			{
				boyfriend.playAnim('deathLoop');
				if(overlay != null && overlay.animation.exists('deathLoop'))
					{
					overlay.visible = true;
					overlay.animation.play('deathLoop');
				}
				justPlayedLoop = true;
			}
		}

		if(!isEnding)
		{
			if (controls.ACCEPT)
			{
				endBullshit();
			}
			else if (controls.BACK)
			{
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
				FlxG.camera.visible = false;
				camHUD.visible = false;
				FlxG.sound.music.stop();
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				PlayState.chartingMode = false;
				PlayState.respawnPoint = 0;
				PlayState.respawned = false;
	
				Mods.loadTopMod();
				MusicBeatState.switchState(new MainMenuState());
	
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				PlayState.instance.callOnScripts('onGameOverConfirm', [false]);
			}
			else if (justPlayedLoop && PlayState.SONG.song != 'UNFUCKABLE')
			{
				coolStartDeath();
			}
			
			if (FlxG.sound.music.playing)
			{
				Conductor.songPosition = FlxG.sound.music.time;
			}
		}
		//PlayState.instance.callOnScripts('onUpdatePost', [elapsed]);
	}

	var isEnding:Bool = false;
	function coolStartDeath(?volume:Float = 1):Void
	{
		if (PlayState.SONG.song != 'UNFUCKABLE')
		{
			FlxG.sound.music.play(true);
		}
		FlxG.sound.music.volume = volume;
	}

	override function beatHit()
	{
		super.beatHit();

		if (fuckbeat && ClientPrefs.data.camZooms)
		{
			camHUD.zoom = 1.1;
			FlxTween.tween(camHUD, {zoom: 1}, 0.4, {ease: FlxEase.quadOut});
		}
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if(PlayState.SONG.song == 'UNFUCKABLE')
			{
				fuckbeat = false;
				if(ClientPrefs.data.flashing){
					tvTransition.visible = true;
					blackBarThingie.visible = true;
					tvTransition.animation.play('dothething', true);
				}
			}
			else
			{
				if(boyfriend.hasAnimation('deathConfirm'))
					boyfriend.playAnim('deathConfirm', true);
				else if(boyfriend.hasAnimation('deathLoop'))
					boyfriend.playAnim('deathLoop', true);
	
				if(overlay != null && overlay.animation.exists('deathConfirm'))
				{
					overlay.visible = true;
					overlay.animation.play('deathConfirm');
					overlay.offset.set(overlayConfirmOffsets.x, overlayConfirmOffsets.y);
				}
			}

			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				camHUD.fade(FlxColor.BLACK, 4, false);
				FlxG.camera.fade(FlxColor.BLACK, 4, false, function()
				{
					if(PlayState.respawnPoint != 0)
					{
						MusicBeatState.switchState(new AdState());
					}
					else
					{
						MusicBeatState.resetState();
					}
				});
			});
			PlayState.instance.callOnScripts('onGameOverConfirm', [true]);
		}
	}

	override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
