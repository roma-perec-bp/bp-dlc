package states.stages;

import shaders.GlitchShader;
import lime.tools.Platform;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import flixel.util.FlxAxes;

import openfl.filters.ShaderFilter;

import objects.VideoSprite;
import lime.app.Application;
import openfl.Lib;

import backend.Song;
import states.stages.objects.*;
import objects.Character;
import objects.Note;

import shaders.VCRMario85;
import shaders.AngelShader;
import shaders.HypnoShader;

import shaders.ShadersHandler;

class Nesbeat extends BaseStage
{
    public static var SONG:SwagSong = null;

    public var nesTweens:Array<FlxTween> = [];
	public var nesTimers:Array<FlxTimer> = [];

    public var vcr:VCRMario85;
    var angel:AngelShader;

	var finalPepShay:GlitchShader;

	var chromacrap:Float = 0;

	var ycbuGyromite:BGSprite;
	var ycbuLakitu:BGSprite;

	var serious:Bool = false;

	var glitchSmall:FlxSprite;
	var glitchSmall2:FlxSprite;
	var glitchBig:FlxSprite;
	var glitchBig1:FlxSprite;
	var glitchBig2:FlxSprite;

	var valEnd:Float = 0;

	var bgPizdec:FlxBackdrop;

	var hypnoBg:FlxSprite;
	var shaderHypno:HypnoShader = null; //fr?

	var fire:FlxSprite;

	var dupeTimer:Int = 0;
	var shit:Float = 0;

	var grass:FlxSprite;
	var roof:FlxSprite;

	var pepperGuy:Bool = false;
	var pidor:Bool = false;

	var cutstatic:BGSprite;
	var grassstatic:BGSprite;
	var roofstatic:BGSprite;

    private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	private var notesString:Array<String> = ['left', 'down', 'up', 'right'];
    var peppers:FlxBackdrop;
	var hwaws:FlxBackdrop;
    public var pepperHold:Float = 0;
	public var hwawHold:Float = 0;

	var blackinfrontobowser:FlxSprite;
	var blackfrontbars:FlxSprite;

    var beatText:FlxText;

    var ycbuLightningL:BGSprite;
	var ycbuLightningR:BGSprite;
	var ycbuHeadL:FlxBackdrop;
	var ycbuHeadR:FlxBackdrop;

	var boomCap:BGSprite;
	var ycbuWhite:FlxSprite;
    var estatica:FlxSprite;

	var walkerZombiesFirst:FlxTypedGroup<ZondbeWalkers>;
	var walkerZombiesSec:FlxTypedGroup<ZondbeWalkers>;
	var walkerZombiesThird:FlxTypedGroup<ZondbeWalkers>;
	var walkerZombiesFourth:FlxTypedGroup<ZondbeWalkers>;
	var walkerZombiesFive:FlxTypedGroup<ZondbeWalkers>;

	var jacks:FlxTypedGroup<Jacksons>;

	var ballons:FlxTypedGroup<ZondbeWalkersRoof>;
	var walkerZombiesBox:FlxTypedGroup<ZondbeWalkersRoof>;
	var walkerZombiesDigger:FlxTypedGroup<ZondbeWalkersRoof>;
	var walkerZombiesGarg:FlxTypedGroup<ZondbeWalkersRoof>;

	var impGroup:FlxTypedGroup<FlxSprite>;

	var notesCamGroup:FlxTypedGroup<FlxSprite>;
	var destructGroup:FlxTypedGroup<FlxSprite>;

	var wabe:FlxSprite;

    var blackBarThingie:FlxSprite;

	var target:FlxSprite;
	var redBrain:Bool = false;

    var whatTheSigma:FlxSprite;

	var brainz:FlxSprite;

	var spawnWalk:Bool = false;
	var insaneSpawn:Bool = false;

	var spawnWalkRoof:Bool = false;

	var darkness:FlxSprite;
	var pepOne:FlxSprite;
	var pepFinal:FlxSprite;

	var pepMan:FlxSprite;

	var handKidnap:FlxSprite;

	var beatusHandsL:FlxSprite;
	var beatusHandsR:FlxSprite;

	var floatshit:Float = 0;

	var boomerActivate:Bool = false;

	var timerTxt:FlxTimer;
	var zombieTime:FlxTimer;

	var boomerLeft1:FlxSprite;
	var boomerLeft2:FlxSprite;
	var boomerLeft3:FlxSprite;
	var boomerLeft4:FlxSprite;

	var boomerRight1:FlxSprite;
	var boomerRight2:FlxSprite;
	var boomerRight3:FlxSprite;
	var boomerRight4:FlxSprite;

	var boomDance:Bool = false;
	var boomDanceRight:Bool = false;
	var boomRight:Bool = false;

	var waveBoom:Bool = false;

	var destruction:Bool = false;
	var chroma:Bool = false;
	var aethosNotes:Bool = false;

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bars', 'death'));
		bg.scale.set(3, 3);
		bg.active = false;
		bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		add(bg);

		bgPizdec = new FlxBackdrop(Paths.image('bars', 'death'));
		bgPizdec.scale.set(3, 3);
		bgPizdec.screenCenter();
		bgPizdec.scrollFactor.set(0.6, 0.6);
		bgPizdec.visible = false;
		add(bgPizdec);

		if (!ClientPrefs.data.lowQuality)
		{
			wabe = new FlxSprite().loadGraphic(Paths.image('wave1/wabe', 'death'));
			wabe.screenCenter();
			wabe.active = false;
			wabe.alpha = 0.6;
			wabe.scrollFactor.set(0, 0);
			wabe.visible = false;
			add(wabe);
		}

		blackfrontbars = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackfrontbars.setGraphicSize(Std.int(blackfrontbars.width * 10));
		blackfrontbars.active = false;
		blackfrontbars.alpha = 0.00001;
		add(blackfrontbars);

		grass = new FlxSprite().loadGraphic(Paths.image('wave2/grass', 'death'));
		grass.scale.set(3, 3);
		grass.active = false;
		grass.screenCenter();
		grass.scrollFactor.set(0.6, 0.6);
		grass.alpha = 0.00001;
		add(grass);

		if (!ClientPrefs.data.lowQuality)
		{
			walkerZombiesFirst = new FlxTypedGroup<ZondbeWalkers>();
			add(walkerZombiesFirst);
			walkerZombiesSec = new FlxTypedGroup<ZondbeWalkers>();
			add(walkerZombiesSec);
			walkerZombiesThird = new FlxTypedGroup<ZondbeWalkers>();
			add(walkerZombiesThird);
			walkerZombiesFourth = new FlxTypedGroup<ZondbeWalkers>();
			add(walkerZombiesFourth);
			walkerZombiesFive = new FlxTypedGroup<ZondbeWalkers>();
			add(walkerZombiesFive);
		}

		roof = new FlxSprite().loadGraphic(Paths.image('wave3/roof', 'death'));
		roof.active = false;
		roof.scale.set(3, 3);
		roof.screenCenter();
		roof.scrollFactor.set(0.6, 0.6);
		roof.alpha = 0.00001;
		add(roof);

		if (!ClientPrefs.data.lowQuality)
		{
			walkerZombiesDigger = new FlxTypedGroup<ZondbeWalkersRoof>();
			add(walkerZombiesDigger);
			walkerZombiesGarg = new FlxTypedGroup<ZondbeWalkersRoof>();
			add(walkerZombiesGarg);
			walkerZombiesBox = new FlxTypedGroup<ZondbeWalkersRoof>();
			add(walkerZombiesBox);
			ballons = new FlxTypedGroup<ZondbeWalkersRoof>();
			add(ballons);

			impGroup = new FlxTypedGroup<FlxSprite>();
			add(impGroup);
		}

		roofstatic = new BGSprite('wave4/roofStat', 800, 300, 0.2, 0.2, ['roof'], true);
		roofstatic.scale.set(1.3, 1.3);
		roofstatic.updateHitbox();
		roofstatic.visible = false;
		roofstatic.screenCenter(XY);
		roofstatic.x -= 125;
		roofstatic.antialiasing = ClientPrefs.data.antialiasing;
		add(roofstatic);

		grassstatic = new BGSprite('wave4/grassStat', 800, 300, 0.2, 0.2, ['grass'], true);
		grassstatic.scale.set(1.3, 1.3);
		grassstatic.updateHitbox();
		grassstatic.visible = false;
		grassstatic.screenCenter(XY);
		grassstatic.x += 125;
		grassstatic.antialiasing = ClientPrefs.data.antialiasing;
		add(grassstatic);

		cutstatic = new BGSprite('wave4/static', 800, 300, 0.2, 0.2, ['static idle'], true);
		cutstatic.scale.set(1.3, 1.3);
		cutstatic.updateHitbox();
		cutstatic.visible = false;
		cutstatic.screenCenter(XY);
		cutstatic.antialiasing = ClientPrefs.data.antialiasing;
		add(cutstatic);

		if(!ClientPrefs.data.lowQuality)
		{
			destructGroup = new FlxTypedGroup<FlxSprite>();
			add(destructGroup);

			fire = new FlxSprite(0, 600);
			fire.frames = Paths.getSparrowAtlas('wave4/Fyre');
			fire.animation.addByPrefix('idle', "Penis instance 1", 24, true);
			fire.animation.play('idle');
			fire.scale.set(3, 3);
			fire.screenCenter(X);
			fire.scrollFactor.set(0.6, 0.6);
			fire.visible = false;
			add(fire);

			notesCamGroup = new FlxTypedGroup<FlxSprite>();
			add(notesCamGroup);

			if(PlayState.reloadEverything)
				for (i in 0...65)
					Paths.image('wave4/icons/' + i);
		}

		blackinfrontobowser = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackinfrontobowser.setGraphicSize(Std.int(blackinfrontobowser.width * 10));
		blackinfrontobowser.alpha = 1;
		blackinfrontobowser.active = false;
		add(blackinfrontobowser);

		blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackBarThingie.setGraphicSize(Std.int(blackBarThingie.width * 10));
		blackBarThingie.alpha = 0.00001;
		blackBarThingie.scrollFactor.set(0, 0);
		blackBarThingie.active = false;
		add(blackBarThingie);

		ycbuWhite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		ycbuWhite.setGraphicSize(Std.int(ycbuWhite.width * 10));
		ycbuWhite.visible = false;
		ycbuWhite.active = false;
		add(ycbuWhite);

		if (!ClientPrefs.data.lowQuality && !ClientPrefs.data.optimize)
		{
			if(ClientPrefs.data.flashing)
			{
				//shoutout to ender and vocal zero for making this in game shader instead of video
				//THAT SHIT BROKE MY OPTIMIZATION
				shaderHypno = new HypnoShader();

				hypnoBg = new FlxSprite(0, 0);
				hypnoBg.loadGraphic(Paths.image('grid', 'shared'));
				hypnoBg.setGraphicSize(FlxG.width * 2, FlxG.height * 2);
				//hypnoBg.blend = MULTIPLY;
				hypnoBg.visible = false;
				hypnoBg.scrollFactor.set(0,0);
				hypnoBg.screenCenter();
				hypnoBg.shader = shaderHypno;
				add(hypnoBg);
			}
		}

        beatText = new FlxText(-230, 150, 1818, '', 24);
		beatText.setFormat(Paths.font("mariones.ttf"), 130, FlxColor.WHITE, CENTER);
		beatText.scrollFactor.set(0, 0);
		beatText.scale.set(1, 1.5);
		beatText.updateHitbox();
		beatText.active = false;
		beatText.screenCenter();
		add(beatText);

		if (!ClientPrefs.data.lowQuality)
		{
			beatusHandsL = new FlxSprite();
			beatusHandsL.frames = Paths.getSparrowAtlas('beatHand');
			beatusHandsL.animation.addByPrefix('idle', "hand_beatUs", 24, true);
			beatusHandsL.animation.play('idle');
			beatusHandsL.antialiasing = ClientPrefs.data.antialiasing;
			beatusHandsL.visible = false;
			beatusHandsL.updateHitbox();
			beatusHandsL.cameras = [camHUD];
			beatusHandsL.active = false;
			add(beatusHandsL);

			beatusHandsR = new FlxSprite(0, 0);
			beatusHandsR.frames = Paths.getSparrowAtlas('beatHand');
			beatusHandsR.animation.addByPrefix('idle', "hand_beatUs", 22, true);
			beatusHandsR.animation.play('idle');
			beatusHandsR.antialiasing = ClientPrefs.data.antialiasing;
			beatusHandsR.visible = false;
			beatusHandsR.flipX = true;
			beatusHandsR.active = false;
			beatusHandsR.updateHitbox();
			beatusHandsR.cameras = [camHUD];
			add(beatusHandsR);

			peppers = new FlxBackdrop();
			peppers.frames = Paths.getSparrowAtlas('wave1/Too_Late_Luigi_Hallway', 'death');
			peppers.animation.addByPrefix('idle', "til idle0",   24, false);
			peppers.animation.addByPrefix('singUP', "til up0", 	 24, false);
			peppers.animation.addByPrefix('singDOWN', "til down0",   24, false);
			peppers.animation.addByPrefix('singLEFT', "til left0",   24, false);
			peppers.animation.addByPrefix('singRIGHT', "til right0", 24, false);
			peppers.animation.play('idle', true);
			peppers.updateHitbox();
			//peppers.scale.set(0.2, 0.2);
			peppers.spacing.set(-1, -1);
			peppers.antialiasing = ClientPrefs.data.antialiasing;
			peppers.velocity.set(500, -450);
			peppers.scrollFactor.set(0,0);
			peppers.alpha = 0.00001;
			add(peppers);

			hwaws = new FlxBackdrop();
			hwaws.frames = Paths.getSparrowAtlas('wave5/hwawLuigi', 'death');
			hwaws.animation.addByPrefix('idle', "idle0",   24, false);
			hwaws.animation.addByPrefix('singUP', "up0", 	 24, false);
			hwaws.animation.addByPrefix('singDOWN', "down0",   24, false);
			hwaws.animation.addByPrefix('singLEFT', "left0",   24, false);
			hwaws.animation.addByPrefix('singRIGHT', "right0", 24, false);
			hwaws.animation.play('idle', true);
			hwaws.updateHitbox();
			hwaws.scale.set(1.5, 1.5);
			hwaws.spacing.set(-1, -1);
			hwaws.antialiasing = false;
			hwaws.velocity.set(1000, -500);
			hwaws.scrollFactor.set(0,0);
			hwaws.alpha = 0.00001;
			add(hwaws);
		}

		if (!ClientPrefs.data.lowQuality)
		{
			boomCap = new BGSprite('boom', 0, 0, 1, 1, ['boom'], true);
			boomCap.animation.addByPrefix('boom', "boom", 24, false);
			boomCap.animation.play('boom', true);
			boomCap.antialiasing = ClientPrefs.data.antialiasing;
			boomCap.cameras = [camHUD];
			boomCap.scale.set(3, 3);
			boomCap.screenCenter();
			boomCap.visible = false;
			add(boomCap);
		}

        ycbuLightningL = new BGSprite('beatuses/ycbu_lightning', 0, 0, 1, 1, ['lightning'], true);
		ycbuLightningL.animation.addByPrefix('idle', "lightning", 15, true);
		ycbuLightningL.animation.play('idle', true);
		ycbuLightningL.screenCenter(XY);
		ycbuLightningL.x -= 440;
		ycbuLightningL.antialiasing = ClientPrefs.data.antialiasing;
		ycbuLightningL.visible = false;
		ycbuLightningL.cameras = [camHUD];
		add(ycbuLightningL);

		ycbuLightningR = new BGSprite('beatuses/ycbu_lightning', 0, 0, 1, 1, ['lightning'], true);
		ycbuLightningR.animation.addByPrefix('idle', "lightning", 15, true);
		ycbuLightningR.flipY = true;
		ycbuLightningR.animation.play('idle', true);
		ycbuLightningR.screenCenter();
		ycbuLightningR.x += 455;
		ycbuLightningR.antialiasing = ClientPrefs.data.antialiasing;
		ycbuLightningR.visible = false;
		ycbuLightningR.cameras = [camHUD];
		add(ycbuLightningR);

        ycbuHeadL = new FlxBackdrop(Y);
		ycbuHeadL.frames = Paths.getSparrowAtlas('beatuses/YouCannotBeatUS_Fellas_Assets', 'death');
		ycbuHeadL.animation.addByPrefix('LOL', "Rotat e", 24, true);
		ycbuHeadL.animation.addByPrefix('gyromite', "Bird Up", 24, false);
		ycbuHeadL.animation.addByPrefix('lakitu', "Lakitu", 24, false);
		ycbuHeadL.animation.play('LOL', true);
		ycbuHeadL.updateHitbox();
		ycbuHeadL.scale.set(0.6, 0.6);
		ycbuHeadL.screenCenter(X);
		ycbuHeadL.x -= 450;
		ycbuHeadL.flipX = true;
		ycbuHeadL.antialiasing = ClientPrefs.data.antialiasing;
		ycbuHeadL.velocity.set(0, 600);
		ycbuHeadL.visible = false;
		ycbuHeadL.cameras = [camHUD];
		add(ycbuHeadL);

		ycbuHeadR = new FlxBackdrop(Y);
		ycbuHeadR.frames = Paths.getSparrowAtlas('beatuses/YouCannotBeatUS_Fellas_Assets', 'death');
		ycbuHeadR.animation.addByPrefix('LOL', "Rotat e", 24, true);
		ycbuHeadR.animation.addByPrefix('gyromite', "Bird Up", 24, false);
		ycbuHeadR.animation.addByPrefix('lakitu', "Lakitu", 24, false);
		ycbuHeadR.animation.play('LOL', true);
		ycbuHeadR.updateHitbox();
		ycbuHeadR.scale.set(0.6, 0.6);
		ycbuHeadR.screenCenter(X);
		ycbuHeadR.x += 445;
		ycbuHeadR.antialiasing = ClientPrefs.data.antialiasing;
		ycbuHeadR.velocity.set(0, -600);
		ycbuHeadR.visible = false;
		ycbuHeadR.cameras = [camHUD];
		add(ycbuHeadR);

		lofiTweensToBeCreepyTo(bg);
		nesTimers.push(new FlxTimer().start(21.5 , function(timer:FlxTimer)
		{
			lofiTweensToBeCreepyTo(bg);
		}, 0));

        estatica = new FlxSprite();
        if (ClientPrefs.data.lowQuality)
        {
            estatica.frames = Paths.getSparrowAtlas('static');
            estatica.setGraphicSize(Std.int(estatica.width * 10));
        }
        else
        {
            estatica.frames = Paths.getSparrowAtlas('Mario_static');
        }
        estatica.animation.addByPrefix('idle', "static play", 15);
        estatica.animation.play('idle');
        estatica.antialiasing = false;
        estatica.cameras = [camHUD];
        estatica.alpha = 0.05;
        estatica.updateHitbox();
        estatica.screenCenter();
        add(estatica);

		whatTheSigma = new FlxSprite().loadGraphic(Paths.image('wave2/what', 'death'));
		whatTheSigma.active = false;
		whatTheSigma.screenCenter();
		whatTheSigma.visible = false;
		whatTheSigma.cameras = [camHudBehind];
		add(whatTheSigma);

		target = new FlxSprite().loadGraphic(Paths.image('wave2/target', 'death'));
		target.visible = false;
		target.screenCenter();
		target.active = false;
		target.cameras = [camHudBehind];
		add(target);

		brainz = new FlxSprite().loadGraphic(Paths.image('wave2/brain', 'death'));
		brainz.screenCenter();
		brainz.visible = false;
		brainz.active = false;
		brainz.cameras = [camHudBehind];
		add(brainz);

		if (!ClientPrefs.data.lowQuality)
		{
			handKidnap = new FlxSprite();
			handKidnap.frames = Paths.getSparrowAtlas('wave3/handKidnap');
			handKidnap.animation.addByPrefix('attack', "kidanp", 24, false);
			handKidnap.animation.play('attack');
			handKidnap.antialiasing = false;
			handKidnap.alpha = 0.00001;
			handKidnap.updateHitbox();
			handKidnap.screenCenter();
			add(handKidnap);

			darkness = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			darkness.alpha = 0.00001;
			darkness.active = false;
			add(darkness);
			darkness.cameras = [camHUD];

			pepOne = new FlxSprite();
			pepOne.frames = Paths.getSparrowAtlas('wave1/youAreOne');
			pepOne.animation.addByPrefix('idle', "one", 24, false);
			pepOne.animation.play('idle');
			pepOne.antialiasing = ClientPrefs.data.antialiasing;
			pepOne.cameras = [camHUD];
			pepOne.updateHitbox();
			pepOne.screenCenter();
			pepOne.alpha = 0.00001;
			add(pepOne);

			if(ClientPrefs.data.shaders) finalPepShay = new GlitchShader();

			pepFinal = new FlxSprite();
			pepFinal.frames = Paths.getSparrowAtlas('wave4/weSex');
			pepFinal.animation.addByPrefix('idle', "brutal", 24, false);
			pepFinal.animation.play('idle');
			pepFinal.antialiasing = ClientPrefs.data.antialiasing;
			pepFinal.cameras = [camHUD];
			pepFinal.scale.set(1.5, 1.5);
			pepFinal.updateHitbox();
			pepFinal.screenCenter();
			pepFinal.visible = false;
			add(pepFinal);


			pepMan = new FlxSprite();
			pepMan.frames = Paths.getSparrowAtlas('wave2/pepBehind');
			pepMan.animation.addByPrefix('idle', "pep_look", 24, false);
			pepMan.animation.play('idle');
			pepMan.antialiasing = ClientPrefs.data.antialiasing;
			pepMan.scale.set(1.5, 1.5);
			pepMan.updateHitbox();
			pepMan.screenCenter(X);
			pepMan.x -= 250;
			pepMan.visible = false;
			add(pepMan);

			glitchSmall = new FlxSprite();
			glitchSmall.frames = Paths.getSparrowAtlas('stagnant_glitch');
			glitchSmall.animation.addByPrefix('idle', "sadface 2", 34, false);
			glitchSmall.animation.play('idle');
			glitchSmall.antialiasing = false;
			glitchSmall.cameras = [camHUD];
			glitchSmall.updateHitbox();
			glitchSmall.alpha = 0.5;
			glitchSmall.setGraphicSize(FlxG.width, FlxG.height);
			glitchSmall.screenCenter();
			glitchSmall.visible = false;
			add(glitchSmall);

			glitchSmall2 = new FlxSprite();
			glitchSmall2.frames = Paths.getSparrowAtlas('screenstatic');
			glitchSmall2.animation.addByPrefix('idle', "screenSTATIC", 24, true);
			glitchSmall2.animation.play('idle');
			glitchSmall2.antialiasing = false;
			glitchSmall2.cameras = [camHUD];
			glitchSmall2.updateHitbox();
			glitchSmall2.screenCenter();
			glitchSmall2.alpha = 0.6;
			glitchSmall2.visible = false;
			add(glitchSmall2);

			glitchBig = new FlxSprite();
			glitchBig.frames = Paths.getSparrowAtlas('Phase3Static');
			glitchBig.animation.addByPrefix('idle', "Phase3Static instance 1", 24, false);
			glitchBig.animation.play('idle');
			glitchBig.antialiasing = false;
			glitchBig.cameras = [camHUD];
			glitchBig.scale.set(4, 4);
			glitchBig.updateHitbox();
			glitchBig.screenCenter();
			glitchBig.alpha = 0.5;
			glitchBig.visible = false;
			add(glitchBig);

			glitchBig1 = new FlxSprite();
			glitchBig1.frames = Paths.getSparrowAtlas('HomeStatic');
			glitchBig1.animation.addByPrefix('idle', "HomeStatic", 24, true);
			glitchBig1.animation.play('idle');
			glitchBig1.antialiasing = false;
			glitchBig1.alpha = 0.00001;
			glitchBig1.cameras = [camHUD];
			glitchBig1.setGraphicSize(FlxG.width, FlxG.height);
			glitchBig1.updateHitbox();
			glitchBig1.screenCenter();
			add(glitchBig1);

			glitchBig2 = new FlxSprite();
			glitchBig2.frames = Paths.getSparrowAtlas('staticBACKGROUND2');
			glitchBig2.animation.addByPrefix('idle', "menuSTATICNEW instance 1", 24, true);
			glitchBig2.animation.play('idle');
			glitchBig2.antialiasing = false;
			glitchBig2.cameras = [camHUD];
			glitchBig2.blend = ADD;
			glitchBig2.alpha = 0.6;
			glitchBig2.visible = false;
			glitchBig2.setGraphicSize(FlxG.width, FlxG.height);
			glitchBig2.updateHitbox();
			glitchBig2.screenCenter();
			add(glitchBig2);
		}

		PlayState.reloadEverything = false;
	}

    override function createPost()
    {
		jacks = new FlxTypedGroup<Jacksons>();
		add(jacks);
		jacks.cameras = [camHUD];

		if(!ClientPrefs.data.lowQuality)
		{
			boomerLeft1 = new FlxSprite(0, FlxG.height ).loadGraphic(Paths.image('wave3/boomers', 'death'), true, 250, 380);
			boomerLeft1.animation.add('idle', [0, 1], 0, false);
			boomerLeft1.animation.play('idle');
			boomerLeft1.cameras = [camHUD];
			boomerLeft1.antialiasing = ClientPrefs.data.antialiasing;
			add(boomerLeft1);
	
			boomerLeft2 = new FlxSprite(boomerLeft1.x + 146, FlxG.height).loadGraphic(Paths.image('wave3/boomers', 'death'), true, 250, 380);
			boomerLeft2.animation.add('idle', [0, 1], 0, false);
			boomerLeft2.animation.play('idle');
			boomerLeft2.cameras = [camHUD];
			boomerLeft2.antialiasing = ClientPrefs.data.antialiasing;
			add(boomerLeft2);
	
			boomerLeft3 = new FlxSprite(boomerLeft2.x + 146, FlxG.height).loadGraphic(Paths.image('wave3/boomers', 'death'), true, 250, 380);
			boomerLeft3.animation.add('idle', [0, 1], 0, false);
			boomerLeft3.animation.play('idle');
			boomerLeft3.cameras = [camHUD];
			boomerLeft3.antialiasing = ClientPrefs.data.antialiasing;
			add(boomerLeft3);
	
			boomerLeft4 = new FlxSprite(boomerLeft3.x + 146, FlxG.height).loadGraphic(Paths.image('wave3/boomers', 'death'), true, 250, 380);
			boomerLeft4.animation.add('idle', [0, 1], 0, false);
			boomerLeft4.animation.play('idle');
			boomerLeft4.cameras = [camHUD];
			boomerLeft4.antialiasing = ClientPrefs.data.antialiasing;
			add(boomerLeft4);

			boomerLeft4.active = false;
			boomerLeft3.active = false;
			boomerLeft2.active = false;
			boomerLeft1.active = false;
	
			boomerRight1 = new FlxSprite(FlxG.width * 0.8, FlxG.height).loadGraphic(Paths.image('wave3/boomers', 'death'), true, 250, 380);
			boomerRight1.animation.add('idle', [0, 1], 0, false);
			boomerRight1.animation.play('idle');
			boomerRight1.cameras = [camHUD];
			boomerRight1.antialiasing = ClientPrefs.data.antialiasing;
			add(boomerRight1);
	
			boomerRight2 = new FlxSprite(boomerRight1.x - 146, FlxG.height).loadGraphic(Paths.image('wave3/boomers', 'death'), true, 250, 380);
			boomerRight2.animation.add('idle', [0, 1], 0, false);
			boomerRight2.animation.play('idle');
			boomerRight2.cameras = [camHUD];
			boomerRight2.antialiasing = ClientPrefs.data.antialiasing;
			add(boomerRight2);
	
			boomerRight3 = new FlxSprite(boomerRight2.x - 146, FlxG.height).loadGraphic(Paths.image('wave3/boomers', 'death'), true, 250, 380);
			boomerRight3.animation.add('idle', [0, 1], 0, false);
			boomerRight3.animation.play('idle');
			boomerRight3.cameras = [camHUD];
			boomerRight3.antialiasing = ClientPrefs.data.antialiasing;
			add(boomerRight3);
	
			boomerRight4 = new FlxSprite(boomerRight3.x - 146, FlxG.height).loadGraphic(Paths.image('wave3/boomers', 'death'), true, 250, 380);
			boomerRight4.animation.add('idle', [0, 1], 0, false);
			boomerRight4.animation.play('idle');
			boomerRight4.cameras = [camHUD];
			boomerRight4.antialiasing = ClientPrefs.data.antialiasing;
			add(boomerRight4);

			boomerRight4.active = false;
			boomerRight3.active = false;
			boomerRight2.active = false;
			boomerRight1.active = false;
		}

		if(ClientPrefs.data.lowQuality)
		{
			ycbuGyromite = new BGSprite('beatuses/YouCannotBeatUS_Fellas_Assets', 800, 1000, 1.1, 1.1, ['Bird Up'], false);
			ycbuGyromite.animation.addByPrefix('idle', "Bird Up", 24, false);
			ycbuGyromite.animation.play('idle', true);
			ycbuGyromite.screenCenter(X);
			ycbuGyromite.y = 200;
			ycbuGyromite.antialiasing = ClientPrefs.data.antialiasing;
		
			ycbuLakitu = new BGSprite('beatuses/YouCannotBeatUS_Fellas_Assets', 0, 1000, 1.1, 1.1, ['Lakitu'], false);
			ycbuLakitu.animation.addByPrefix('idle', "Lakitu", 24, false);
			ycbuLakitu.animation.play('idle', true);
			ycbuLakitu.screenCenter(X);
			ycbuLakitu.flipX = true;
			ycbuLakitu.x -= 100;
			ycbuLakitu.y = 200;
			ycbuLakitu.antialiasing = ClientPrefs.data.antialiasing;
		
			ycbuGyromite.visible = false;
			ycbuLakitu.visible = false;
			add(ycbuGyromite);
			add(ycbuLakitu);
		}

		if (ClientPrefs.data.tvEffect)
		{
			vcr = new VCRMario85();
	
			angel = new AngelShader();
	
			camHUD.setFilters([ShadersHandler.chromaticAberration, new ShaderFilter(vcr)]);
			camHudBehind.setFilters([ShadersHandler.chromaticAberration, new ShaderFilter(vcr)]);
			camGame.setFilters([ShadersHandler.chromaticAberration, new ShaderFilter(vcr), new ShaderFilter(angel)]);

			ShadersHandler.setChrome(0);
		}
		else if(ClientPrefs.data.shaders && !ClientPrefs.data.lowQuality)
		{
			camHUD.setFilters([ShadersHandler.chromaticAberration]);
			camHudBehind.setFilters([ShadersHandler.chromaticAberration]);
			camGame.setFilters([ShadersHandler.chromaticAberration]);

			ShadersHandler.setChrome(0);
		}

		camHUD.alpha = 0.00001;
		boyfriend.visible = false;
		dad.visible = false;
		mom.visible = false;
		bro.visible = false;
		gf.visible = false;
    }

    var val:Float = 0;
    override function update(elapsed:Float)
    {
        if(game.startingSong && !ClientPrefs.data.lowQuality)
        {
            if (dad.getAnimationName().startsWith('sing')) pepperHold += elapsed;

            if (pepperHold >= Conductor.stepCrochet * (0.0011 #if FLX_PITCH / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1) #end) * dad.singDuration)
            {
                peppers.animation.play('idle', true);
                pepperHold = 0;
            }

			if (boyfriend.getAnimationName().startsWith('sing')) hwawHold += elapsed;

            if (hwawHold >= Conductor.stepCrochet * (0.0011 #if FLX_PITCH / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1) #end) * boyfriend.singDuration)
            {
                hwaws.animation.play('idle', true);
                hwawHold = 0;
            }
        }

        if(angel != null){
			if(ClientPrefs.data.flashing) angel.strength = FlxMath.lerp(angel.strength, 0, FlxMath.bound(elapsed * 4, 0, 1));

			angel.pixelSize = FlxMath.lerp(angel.pixelSize, 1, FlxMath.bound(elapsed * 4, 0, 1));
			angel.data.iTime.value = [Conductor.songPosition / 1000];
		}

		if (vcr != null) vcr.update(elapsed);

		if (hypnoBg != null) hypnoBg.shader.data.iTime.value[0] += elapsed;

		if (!ClientPrefs.data.lowQuality)
		{
			floatshit += 0.05;
			beatusHandsL.y += Math.sin(floatshit) * (elapsed/(1/60));
			beatusHandsR.y -= Math.sin(floatshit) * (elapsed/(1/60));

			if(finalPepShay != null) finalPepShay.update(elapsed);

			if(ClientPrefs.data.shaders)
				ShadersHandler.setChrome(chromacrap);
		}
    }

	override function eventCalled(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, flValue1:Null<Float>, flValue2:Null<Float>, flValue3:Null<Float>, flValue4:Null<Float>, flValue5:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case 'bg hypno':
				if(hypnoBg == null) return;

				hypnoBg.visible = !hypnoBg.visible;
	

			case 'ycbu text':
				var pibetexto:String = value1.replace(';', '\n');

				if (ClientPrefs.data.flashing)
					beatText.color = 0xFFF87858;

				beatText.text = pibetexto;
				beatText.updateHitbox();
				beatText.screenCenter();

				if(timerTxt != null) timerTxt.cancel();

				timerTxt = new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					if(value3 != 'black')
						beatText.color = FlxColor.WHITE;
					else
						beatText.color = FlxColor.BLACK;
				});

				switch(value2){
					case 'lawn':
						ycbuHeadL.animation.play('gyromite', true);
						ycbuHeadR.animation.play('gyromite', true);
					case 'box':
						ycbuHeadL.animation.play('lakitu', true);
						ycbuHeadR.animation.play('lakitu', true);
					case 'box final':
						ycbuHeadR.animation.play('lakitu', true);
					case 'final':
						ycbuHeadL.animation.play('gyromite', true);
						ycbuHeadR.animation.play('lakitu', true);
					case 'low':
						if(ClientPrefs.data.lowQuality)
						{
							ycbuGyromite.animation.play('idle', true);
							ycbuLakitu.animation.play('idle', true);
						}
				}

			case 'UNFUCK TRIGGERS':
				switch(value1)
				{
					case '0': //ИНТРО
						FlxTween.tween(blackinfrontobowser, {alpha: 0.3}, 8, {ease: FlxEase.quadInOut});
					case '1': //ХУД
						FlxTween.tween(camHUD, {alpha: 1}, 5, {ease: FlxEase.quadInOut});
					case '2': //БЛЯ
					    goingNuts();
					case '3': //уходить волна 1
						bgPizdec.visible = false;
					case '4': //для финала
						bgPizdec.visible = true;
						FlxTween.cancelTweensOf(blackinfrontobowser);
						blackinfrontobowser.alpha = 0.6;
					case '5': //Нахуй Чернуху
					    FlxTween.cancelTweensOf(blackinfrontobowser);
					    blackinfrontobowser.alpha = 0.00001;
					case '6': //nvm
					    FlxTween.cancelTweensOf(blackinfrontobowser);
						blackinfrontobowser.alpha = 1;
					case '7': //идет трава
					    grass.alpha += 0.1;
					case '8': //волна два
						grass.alpha = 1;
						zombieTime = new FlxTimer().start(1, function(timer:FlxTimer)
						{
							spawnZombie();
						}, 5);
					case '9': //ЧЕРНОТА
						FlxTween.tween(blackfrontbars, {alpha: 1}, 2);
					case '10': //нах черных
					    blackfrontbars.alpha = 0.00001;
					case '11': //черные но платить короче альфа бля
						FlxTween.tween(blackinfrontobowser, {alpha: flValue2}, flValue3);
					case '12': //без твтина
					    blackinfrontobowser.alpha = flValue2;
					case '13': //чето под бит
						var split:Array<String> = value2.split(',');
						dupeTimer = Std.parseInt(split[1]);
						shit = Std.parseFloat(split[0]);
					case '14': //нахуй траву
						FlxTween.tween(grass, {alpha: 0.00001}, 3);
						
						if (!ClientPrefs.data.lowQuality)
						{
							walkerZombiesFirst.forEach(function(spr:ZondbeWalkers)
							{
								FlxTween.tween(spr, {alpha: 0}, 3, {onComplete: function(twn:FlxTween){
									spr.kill();
									walkerZombiesFirst.remove(spr, true);
									spr.destroy();
								}});
							});
							walkerZombiesSec.forEach(function(spr:ZondbeWalkers)
							{
								FlxTween.tween(spr, {alpha: 0}, 3, {onComplete: function(twn:FlxTween)
								{
									spr.kill();
									walkerZombiesSec.remove(spr, true);
									spr.destroy();
								}});
							});
							walkerZombiesThird.forEach(function(spr:ZondbeWalkers)
							{
								FlxTween.tween(spr, {alpha: 0}, 3, {onComplete: function(twn:FlxTween)
								{
									spr.kill();
									walkerZombiesThird.remove(spr, true);
									spr.destroy();
								}});
							});
							walkerZombiesFourth.forEach(function(spr:ZondbeWalkers)
							{
								FlxTween.tween(spr, {alpha: 0}, 3, {onComplete: function(twn:FlxTween)
								{
									spr.kill();
									walkerZombiesFourth.remove(spr, true);
									spr.destroy();
								}});
							});
							walkerZombiesFive.forEach(function(spr:ZondbeWalkers)
							{
								FlxTween.tween(spr, {alpha: 0}, 3, {onComplete: function(twn:FlxTween)
								{
									spr.kill();
									walkerZombiesFive.remove(spr, true);
									spr.destroy();
								}});
							});
						}
					case '15': //волна три
						FlxTween.tween(roof, {alpha: 1}, 1);
					case '16': //ночь крыша
					    roof.loadGraphic(Paths.image('wave3/roofNight', 'death'));
					case '17': //идет нах
					    FlxTween.tween(roof, {alpha: 0.00001}, 10);
						FlxTween.tween(blackinfrontobowser, {alpha: 0.7}, 5, {ease: FlxEase.quadInOut});
					case '18': 
						FlxTween.tween(blackfrontbars, {alpha: 0.00001}, 15);
					case '19': //dada
						FlxTween.tween(blackfrontbars, {alpha: 1}, 2);
					case '21': //statics grass
					    cutstatic.visible = grassstatic.visible = true;
					case '22': //statics roof
					    roofstatic.visible = true;
					case '23': //CLEAR BEFORE FINAL
					    cutstatic.visible = grassstatic.visible = roofstatic.visible = false;
						if (!ClientPrefs.data.lowQuality) fire.visible = false;
						destruction = false;

						if (!ClientPrefs.data.lowQuality)
						{
							destructGroup.forEach(function(spr:FlxSprite)
								{
									FlxTween.cancelTweensOf(spr);
									spr.kill();
									destructGroup.remove(spr, true);
									spr.destroy();
								});
						}
					case '24': //Нахуй Чернуху
						FlxTween.tween(blackinfrontobowser, {alpha: 0.00001}, 0.5);
					case '25': //активировать зомби
					    spawnWalk = true;
					case '26': //активировать пиздец
					    insaneSpawn = true;
					case '27': //всо
					    insaneSpawn = false;
						spawnWalk = false;
					case '28': //спавн дахуя
					    for (i in 0...12)
							spawnZombie(true);
					case '29': //what
						whatTheSigma.visible = !whatTheSigma.visible;
					case '30': //цель мозг
						target.visible = true;

						redBrain = !redBrain;

						if(redBrain)
							target.color = 0xFFFF0000;
						else
							target.color = 0xFFFFFFFF;
					case '31': //мозг разжижается
						FlxTween.tween(camHudBehind, {zoom: 2}, Conductor.stepCrochet * 16 / 1000, {ease: FlxEase.expoIn});
					case '32': //камера назад
					    camHudBehind.zoom = 1;
						target.visible = false;
					case '33': //МОЗГИ
						brainz.visible = !brainz.visible;
						camHudBehind.shake(0.05, 0.2);
					case '34': //спавн
					    for (i in 0...5)
							spawnZombie(true);
					case '35': //игры кончились
						serious = !serious;
					case '36': //ТЫ ОДИН
					    if (ClientPrefs.data.lowQuality) return;

						FlxTween.tween(darkness, {alpha: 0.6}, 0.5);
						pepOne.alpha = 1;
						pepOne.animation.play('idle', true);

						pepOne.animation.finishCallback = function(pog:String)
						{
							pepOne.alpha = 0.00001;
							darkness.alpha = 0.00001;
						}
					case '37': //перец сзади
					    if (ClientPrefs.data.lowQuality) return;
						pepMan.visible = true;
						pepMan.animation.play('idle', true);
					case '38': //пошел
					    if (!ClientPrefs.data.lowQuality)
							pepMan.visible = false;
					case '39': //ручки
					    if (ClientPrefs.data.lowQuality) return;

						beatusHandsL.animation.play('idle');
						beatusHandsR.animation.play('idle');

						beatusHandsL.visible = !beatusHandsL.visible;
						beatusHandsR.visible = !beatusHandsR.visible;
					case '40': //бумеры
						boomerActivate = !boomerActivate;
					case '41': //активировать зомби
					    spawnWalkRoof = true;
					case '42': //море волнуется раз
					    if (ClientPrefs.data.lowQuality) return;
						
					    boomerRight1.animation.curAnim.curFrame = 1;
						boomerRight2.animation.curAnim.curFrame = 1;
						boomerRight3.animation.curAnim.curFrame = 1;
						boomerRight4.animation.curAnim.curFrame = 1;
						boomerLeft1.animation.curAnim.curFrame = 1;
						boomerLeft2.animation.curAnim.curFrame = 1;
						boomerLeft3.animation.curAnim.curFrame = 1;
						boomerLeft4.animation.curAnim.curFrame = 1;

					    if(waveBoom)
						{
							FlxTween.tween(boomerLeft1, {y: FlxG.height * 0.5}, 1, {ease: FlxEase.sineOut,
								onComplete: function(tween:FlxTween)
								{
									FlxTween.tween(boomerLeft1, {y: FlxG.height}, 1, {ease: FlxEase.sineIn});
								}});
	
							FlxTween.tween(boomerLeft2, {y: FlxG.height * 0.5}, 1, {ease: FlxEase.sineOut, startDelay: 0.2,
								onComplete: function(tween:FlxTween)
								{
									FlxTween.tween(boomerLeft2, {y: FlxG.height}, 1, {ease: FlxEase.sineIn});
								}});
	
							FlxTween.tween(boomerLeft3, {y: FlxG.height * 0.5}, 1, {ease: FlxEase.sineOut, startDelay: 0.4,
								onComplete: function(tween:FlxTween)
								{
									FlxTween.tween(boomerLeft3, {y: FlxG.height}, 1, {ease: FlxEase.sineIn});
								}});
	
							FlxTween.tween(boomerLeft4, {y: FlxG.height * 0.5}, 1, {ease: FlxEase.sineOut, startDelay: 0.6,
								onComplete: function(tween:FlxTween)
								{
									FlxTween.tween(boomerLeft4, {y: FlxG.height}, 1, {ease: FlxEase.sineIn});
								}});
						}
						else
						{
							FlxTween.tween(boomerRight1, {y: FlxG.height * 0.5}, 1, {ease: FlxEase.sineOut,
								onComplete: function(tween:FlxTween)
								{
									FlxTween.tween(boomerRight1, {y: FlxG.height}, 1, {ease: FlxEase.sineIn});
								}});
	
							FlxTween.tween(boomerRight2, {y: FlxG.height * 0.5}, 1, {ease: FlxEase.sineOut, startDelay: 0.2,
								onComplete: function(tween:FlxTween)
								{
									FlxTween.tween(boomerRight2, {y: FlxG.height}, 1, {ease: FlxEase.sineIn});
								}});
	
							FlxTween.tween(boomerRight3, {y: FlxG.height * 0.5}, 1, {ease: FlxEase.sineOut, startDelay: 0.4,
								onComplete: function(tween:FlxTween)
								{
									FlxTween.tween(boomerRight3, {y: FlxG.height}, 1, {ease: FlxEase.sineIn});
								}});
	
							FlxTween.tween(boomerRight4, {y: FlxG.height * 0.5}, 1, {ease: FlxEase.sineOut, startDelay: 0.6,
								onComplete: function(tween:FlxTween)
								{
									FlxTween.tween(boomerRight4, {y: FlxG.height}, 1, {ease: FlxEase.sineIn});
								}});
						}

						waveBoom = !waveBoom;
					case "43": //KILL ZONDRIES
					    spawnWalkRoof = false;
						if (ClientPrefs.data.lowQuality) return;
						
					    ballons.forEach(function(spr:ZondbeWalkersRoof)
						{
							FlxTween.tween(spr, {alpha: 0}, 3, {onComplete: function(twn:FlxTween)
							{
								spr.kill();
								ballons.remove(spr, true);
								spr.destroy();
							}});
						});
						walkerZombiesDigger.forEach(function(spr:ZondbeWalkersRoof)
						{
							FlxTween.tween(spr, {alpha: 0}, 3, {onComplete: function(twn:FlxTween)
							{
								spr.kill();
								walkerZombiesDigger.remove(spr, true);
								spr.destroy();
							}});
						});
						walkerZombiesBox.forEach(function(spr:ZondbeWalkersRoof)
						{
							FlxTween.tween(spr, {alpha: 0}, 3, {onComplete: function(twn:FlxTween)
							{
								spr.kill();
								walkerZombiesBox.remove(spr, true);
								spr.destroy();
							}});
						});
						walkerZombiesGarg.forEach(function(spr:ZondbeWalkersRoof)
						{
							FlxTween.tween(spr, {alpha: 0}, 3, {onComplete: function(twn:FlxTween)
							{
								spr.kill();
								walkerZombiesGarg.remove(spr, true);
								spr.destroy();
							}});
						});
					case '44': //ПОХИЩЕНИЕ
					    if (ClientPrefs.data.lowQuality) return;

						FlxTween.tween(handKidnap, {alpha: 1}, 1);
						handKidnap.animation.play('attack', true);

						handKidnap.animation.finishCallback = function(pog:String)
						{
							handKidnap.alpha = 0.00001;
						}
					case '45': //через огонь
					if (!ClientPrefs.data.lowQuality) fire.visible = true;

					case '46': //уничтожение
					    destruction = !destruction;

					case '47': //МБЭИТНЕБН
					    if (ClientPrefs.data.lowQuality) return;

						FlxTween.tween(darkness, {alpha: 0.6}, 0.5);
						pepFinal.alpha = 1;
						pepFinal.visible = true;
						pepFinal.animation.play('idle', true);

						pepFinal.animation.finishCallback = function(pog:String)
						{
							pepFinal.visible = false;
							darkness.alpha = 0.00001;
							pepFinal.shader = null;
						}

					case '48': //aethos reference
						aethosNotes = !aethosNotes;

					case '49': //end static
						new FlxTimer().start(2, function(timer:FlxTimer)
						{
							FlxTween.tween(game, {health: 0.001}, 4, {ease: FlxEase.expoIn});
						});
						FlxG.camera.flash(FlxColor.WHITE, 2);
						FlxG.camera.shake(0.003, 2);
						camHUD.shake(0.003, 2);

					case '50':
						Lib.application.window.title = "YOU CANNOT FUCK US";

					case '51':
						game.ycfu = true;

					case '52':
						game.ycfu2 = true;

					case '53':
						if(!ClientPrefs.data.lowQuality && ClientPrefs.data.shaders)
							pepFinal.shader = finalPepShay;

					case '54':
						ycbuWhite.visible = true;

					case '55':
						ycbuWhite.visible = false;

					case '56':
						if(ClientPrefs.data.lowQuality) ycbuGyromite.visible = !ycbuGyromite.visible;

					case '57':
						if(ClientPrefs.data.lowQuality) ycbuLakitu.visible = !ycbuLakitu.visible;

					case '58':
						if(ClientPrefs.data.lowQuality)
						{
							ycbuLakitu.x = 1100;
							ycbuGyromite.x = -100;
							ycbuLakitu.y = 400;
							ycbuGyromite.y = 400;
						}
					case '59':
						chroma = !chroma;

					case '60': //на случай если будет лаг
					if(!ClientPrefs.data.lowQuality)
					{
						FlxTween.tween(boomerRight1, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerRight2, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerRight3, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerRight4, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerRight1, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerRight2, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerRight3, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerRight4, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
					}

					case '61': //анти фриз xd
						if(ClientPrefs.data.lowQuality) return;

						pepOne.alpha = 0.00001;
						darkness.alpha = 0.00001;

					case '62':
						FlxTween.cancelTweensOf(blackinfrontobowser);
						blackinfrontobowser.alpha = 0.0001;

						if(hypnoBg == null) return;

						hypnoBg.visible = true;
						hypnoBg.shader.data.alphaShitLmao.value[0] = 1;

					case '63':
						cutstatic.visible = grassstatic.visible = roofstatic.visible = true;
						if (!ClientPrefs.data.lowQuality) fire.visible = true;
						
						if(hypnoBg == null) return;

						hypnoBg.visible = false;
						hypnoBg.shader.data.alphaShitLmao.value[0] = .3;

					case '64':
						cutstatic.visible = grassstatic.visible = roofstatic.visible = false;
						blackfrontbars.alpha = 1;

					case '65':
						estatica.alpha = 0.6;
						FlxTween.tween(estatica, {alpha: 0.05}, 0.5, {ease: FlxEase.quadInOut});
				}

			case 'BACKDROP GUYS':
				if(ClientPrefs.data.lowQuality) return;

				pepperGuy = !pepperGuy;
				peppers.alpha = pepperGuy ? 1 : 0.00001;

			case 'BACKDROP HWAW':
				if(ClientPrefs.data.lowQuality) return;
	
				pidor = !pidor;
				hwaws.alpha = pidor ? 1 : 0.00001;

			case 'BEATUS TRIGGERS':
				switch(value1)
				{
					case '0': //уходить
						if(ClientPrefs.data.flashing && ClientPrefs.data.tvEffect) 
							angel.strength = 0.325;

						ycbuLightningL.visible = ycbuLightningR.visible = ycbuHeadL.visible = ycbuHeadR.visible = false;

					case '1': //пришли
					    if(ClientPrefs.data.flashing && ClientPrefs.data.tvEffect) 
							angel.strength = 0.325;

						ycbuHeadL.velocity.y = 600;
						ycbuHeadR.velocity.y = -600;
						ycbuLightningL.screenCenter(X);
						ycbuLightningR.screenCenter(X);
						ycbuLightningL.x -= 440;
						ycbuLightningR.x += 455;
						ycbuLightningL.visible = ycbuLightningR.visible = ycbuHeadL.visible = ycbuHeadR.visible = true;

					case '2': //reverse direction
						if (Math.abs(ycbuHeadL.velocity.y) != 1 && ycbuHeadL.animation.curAnim.name == 'LOL' && ClientPrefs.data.flashing && ClientPrefs.data.tvEffect)
							angel.strength = 0.1;
									
						FlxTween.tween(ycbuHeadL, {y: ycbuHeadL.y + (ycbuHeadL.velocity.y)}, 0.1, {ease: FlxEase.quadOut});
						FlxTween.tween(ycbuHeadR, {y: ycbuHeadR.y + (ycbuHeadR.velocity.y)}, 0.1, {ease: FlxEase.quadOut});
						FlxTween.tween(ycbuHeadL.velocity, {y: ycbuHeadL.velocity.y * -1}, 0.1, {ease: FlxEase.quadOut});
						FlxTween.tween(ycbuHeadR.velocity, {y: ycbuHeadR.velocity.y * -1}, 0.1, {ease: FlxEase.quadOut});

					case '3': //skip
						if (Math.abs(ycbuHeadL.velocity.y) != 1 && ycbuHeadL.animation.curAnim.name == 'LOL' && ClientPrefs.data.flashing && ClientPrefs.data.tvEffect)
							angel.strength = 0.1;

						FlxTween.tween(ycbuHeadL, {y: ycbuHeadL.y + (250 * (ycbuHeadL.velocity.y / Math.abs(ycbuHeadL.velocity.y)))}, 0.25, {ease: FlxEase.quadOut});
						FlxTween.tween(ycbuHeadR, {y: ycbuHeadR.y + (250 * (ycbuHeadR.velocity.y / Math.abs(ycbuHeadR.velocity.y)))}, 0.25, {ease: FlxEase.quadOut});

					case '4': //stop
						ycbuHeadL.velocity.y /= Math.abs(ycbuHeadL.velocity.y);
						ycbuHeadR.velocity.y /= Math.abs(ycbuHeadR.velocity.y);

					case '5': //start
						ycbuHeadL.velocity.y *= 420;
						ycbuHeadR.velocity.y *= 420;

					case '6': //swap spots
						var firstX:Float = ycbuHeadL.x;
						FlxTween.tween(ycbuHeadL, {x: ycbuHeadR.x}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(ycbuHeadR, {x: firstX}, 0.2, {ease: FlxEase.quadOut});
						firstX = ycbuLightningL.x;
						FlxTween.tween(ycbuLightningL, {x: ycbuLightningR.x}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(ycbuLightningR, {x: firstX}, 0.2, {ease: FlxEase.quadOut});

					case '7': //swap to heads
						ycbuHeadL.animation.play('LOL', true);
						ycbuHeadR.animation.play('LOL', true);
						ycbuHeadL.spacing.y = 100;
						ycbuHeadR.spacing.y = 100;
						ycbuHeadL.flipX = true;
						ycbuHeadR.flipX = false;
						ycbuHeadL.screenCenter(X);
						ycbuHeadL.x -= 440;
						ycbuHeadR.screenCenter(X);
						ycbuHeadR.x += 440;

					case '8': //swap to lawn
						ycbuHeadL.animation.play('gyromite', true);
						ycbuHeadR.animation.play('gyromite', true);
						ycbuHeadL.spacing.y = 150;
						ycbuHeadR.spacing.y = 150;
						ycbuHeadL.flipX = false;
						ycbuHeadR.flipX = true;
						ycbuHeadL.x = -30;
						ycbuHeadR.x = 870;

					case '9': //swap to box
						ycbuHeadL.animation.play('lakitu', true);
						ycbuHeadR.animation.play('lakitu', true);
						ycbuHeadL.spacing.y = 200;
						ycbuHeadR.spacing.y = 200;
						ycbuHeadL.flipX = false;
						ycbuHeadR.flipX = true;
						ycbuHeadL.x = -50;
						ycbuHeadR.x = 900;

					case '10': //lawn left
					    if(ClientPrefs.data.flashing && ClientPrefs.data.tvEffect) 
							angel.strength = 0.325;

						ycbuHeadL.velocity.y = 600;
						ycbuLightningL.screenCenter(X);
						ycbuLightningL.x -= 440;
						ycbuLightningL.visible = ycbuHeadL.visible = true;

						ycbuHeadL.animation.play('gyromite', true);
						ycbuHeadL.spacing.y = 150;
						ycbuHeadL.flipX = false;
						ycbuHeadL.x = -30;

					case '11': //box right
					    if(ClientPrefs.data.flashing && ClientPrefs.data.tvEffect) 
							angel.strength = 0.325;

						ycbuHeadR.velocity.y = -600;
						ycbuLightningR.screenCenter(X);
						ycbuLightningR.x += 455;
						ycbuLightningR.visible = ycbuHeadR.visible = true;

						ycbuHeadR.animation.play('lakitu', true);
						ycbuHeadR.spacing.y = 200;
						ycbuHeadR.flipX = true;
						ycbuHeadR.x = 900;
				}

			case 'CapCut Boom':
				if (ClientPrefs.data.lowQuality) return;
				boomCap.visible = true;
				boomCap.animation.play('boom', true);

				new FlxTimer().start(1.5, function(timer:FlxTimer)
				{
					boomCap.visible = false;
				});

			case 'We Are Brutal Ex':
				if (!ClientPrefs.data.lowQuality) wabe.visible = !wabe.visible;

			case 'Glitch Small':
				if (ClientPrefs.data.lowQuality) return;

				switch(value1)
				{
					case '1':
						glitchSmall.visible = true;
						
						glitchSmall.animation.play('idle', true);

						glitchSmall.animation.finishCallback = function(pog:String)
						{
							glitchSmall.visible = false;
						}
					case '2':
						glitchSmall2.visible = !glitchSmall2.visible;
				}
			case 'Glitch Big':
				if (ClientPrefs.data.lowQuality) return;
				
				switch(value1)
				{
					case '1':
						glitchBig.visible = true;
						glitchBig.animation.play('idle', true);

						glitchBig.animation.finishCallback = function(pog:String)
						{
							glitchBig.visible = false;
						}
					case '2':
						FlxTween.tween(glitchBig1, {alpha: 0.6}, 0.3, {
							onComplete: function(tween:FlxTween)
							{
								FlxTween.tween(glitchBig1, {alpha: 0.00001}, 0.6);
							}
						});
					case '3':
						glitchBig2.visible = !glitchBig2.visible;
				}

			case 'Force Dance':
				if (!ClientPrefs.data.lowQuality)
					peppers.animation.play('idle', true);

			case 'Jackson Hud':
				spawnJackson();

			case 'Respawn Clear': //used so after skipping time no shit happens
			    if(PlayState.respawned)
				{
					camGame.stopFX(); //FOR FUCK SAKE FIANLLY
					camHUD.stopFX();
	
					game.resetCamera();
	
					game.cancelAllCameraTweens();
					game.resetCameraZoom();
	
					FlxTween.cancelTweensOf(camHudBehind);

					PlayState.respawned = false;
				}

				PlayState.respawnPoint++;

				if(!ClientPrefs.data.lowQuality)
				{
					FlxTween.cancelTweensOf(darkness);

					if(zombieTime != null) zombieTime.cancel();

					pepOne.alpha = 0.00001;
					darkness.alpha = 0.00001;
					pepFinal.visible = false;

					glitchSmall.visible = false;
					glitchBig.visible = false;
	
					FlxTween.cancelTweensOf(glitchBig1);
					glitchBig1.alpha = 0.00001;
	
					boomCap.visible = false;

					FlxTween.cancelTweensOf(handKidnap);
					handKidnap.alpha = 0.00001;

					FlxTween.cancelTweensOf(boomerRight1);
					FlxTween.cancelTweensOf(boomerRight2);
					FlxTween.cancelTweensOf(boomerRight3);
					FlxTween.cancelTweensOf(boomerRight4);
	
					boomerRight1.y = FlxG.height;
					boomerRight2.y = FlxG.height;
					boomerRight3.y = FlxG.height;
					boomerRight4.y = FlxG.height;
	
					FlxTween.cancelTweensOf(boomerLeft1);
					FlxTween.cancelTweensOf(boomerLeft2);
					FlxTween.cancelTweensOf(boomerLeft3);
					FlxTween.cancelTweensOf(boomerLeft4);
	
					boomerLeft1.y = FlxG.height;
					boomerLeft2.y = FlxG.height;
					boomerLeft3.y = FlxG.height;
					boomerLeft4.y = FlxG.height;
				}

				jacks.forEach(function(spr:Jacksons)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.00001, {onComplete: function(twn:FlxTween){ //so they WILL be deleted
						spr.kill();
						jacks.remove(spr, true);
						spr.destroy();
					}});
				});
		}
	}

    override function beatHit()
	{
		if(!ClientPrefs.data.lowQuality)
		{
			if(spawnWalkRoof)
			{
				if (FlxG.random.bool(24)) spawnZombieRoof(0);
		
				if (FlxG.random.bool(0.5)) spawnZombieRoof(3);
		
				if (FlxG.random.bool(2)) spawnZombieRoof(1);
		
				if (FlxG.random.bool(4)) spawnZombieRoof(2);
		
				if(FlxG.random.bool(10)) fallingImps();
			}

			if (curBeat % dad.danceEveryNumBeats == 0 && !dad.getAnimationName().startsWith('sing') && !dad.stunned)
				peppers.animation.play('idle', true);

			if(destruction)
			{
				if (FlxG.random.bool(50))
				{
					var which = FlxG.random.int(0, 2);
					var appear:Float = 0;

					switch(which)
					{
						case 0:
							FlxG.random.float(700, 1280);
						case 1:
							FlxG.random.float(0, 200);
						case 2:
							FlxG.random.float(200, 700);
					}

					var sparkles:FlxSprite = new FlxSprite(appear, 0);
					sparkles.frames = Paths.getSparrowAtlas('wave4/sparkles');
					sparkles.animation.addByPrefix('idle', "spark"+which, 24, false);
					sparkles.animation.play('idle');
					sparkles.antialiasing = ClientPrefs.data.antialiasing;
					sparkles.updateHitbox();
					sparkles.scale.set(2, 2);
					sparkles.scrollFactor.set(0.6, 0.6);
					destructGroup.add(sparkles);

					sparkles.animation.finishCallback = function(pog:String)
					{
						sparkles.kill();
						destructGroup.remove(sparkles, true);
						sparkles.destroy();
					}
				}

				if (FlxG.random.bool(25))
				{
					var objFall:FlxSprite = new FlxSprite(FlxG.random.float(200, 1000), -100);
					objFall.frames = Paths.getSparrowAtlas('wave4/fall');
					objFall.animation.addByPrefix('idle', "fall"+FlxG.random.int(0, 1), 24, false);
					objFall.animation.play('idle');
					objFall.antialiasing = ClientPrefs.data.antialiasing;
					objFall.scrollFactor.set(0.6, 0.6);
					objFall.updateHitbox();
					destructGroup.add(objFall);

					objFall.velocity.y = FlxG.random.float(1000, 2000);

					if(objFall.y >= 1500)
					{
						objFall.kill();
						destructGroup.remove(objFall, true);
						objFall.destroy();
					}
				}

				if (FlxG.random.bool(50))
				{
					var iconFall:FlxSprite = new FlxSprite(FlxG.random.float(0, 1280), -100).loadGraphic(Paths.image('wave4/icons/'+FlxG.random.int(0, 65)));
					iconFall.antialiasing = ClientPrefs.data.antialiasing;
					iconFall.scrollFactor.set(0.6, 0.6);
					iconFall.updateHitbox();
					destructGroup.add(iconFall);

					iconFall.velocity.y = FlxG.random.float(200, 1000);
					FlxTween.tween(iconFall, {angle: 360}, FlxG.random.float(0.5, 3), {type: LOOPING,
						onComplete: function(tween:FlxTween)
						{
							iconFall.angle = 0;
						}
					});

					if(iconFall.y >= 1500)
					{
						iconFall.kill();
						destructGroup.remove(iconFall, true);
						iconFall.destroy();
					}
				}
			}

			if(boomerActivate)
			{
				if(boomRight)
				{
					FlxTween.cancelTweensOf(boomerRight1);
					FlxTween.cancelTweensOf(boomerRight2);
					FlxTween.cancelTweensOf(boomerRight3);
					FlxTween.cancelTweensOf(boomerRight4);

					boomerRight1.animation.curAnim.curFrame = (boomDanceRight) ? 1 : 0;
					boomerRight2.animation.curAnim.curFrame = (boomDanceRight) ? 1 : 0;
					boomerRight3.animation.curAnim.curFrame = (boomDanceRight) ? 1 : 0;
					boomerRight4.animation.curAnim.curFrame = (boomDanceRight) ? 1 : 0;

					if(boomDanceRight)
					{
						FlxTween.tween(boomerRight1, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerRight2, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerRight3, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerRight4, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});

						boomRight = false;
					}
					else
					{
						FlxTween.tween(boomerRight1, {y: FlxG.height * 0.5}, Conductor.crochet * 0.002, {ease: FlxEase.backOut});
						FlxTween.tween(boomerRight2, {y: FlxG.height * 0.5}, Conductor.crochet * 0.002, {ease: FlxEase.backOut});
						FlxTween.tween(boomerRight3, {y: FlxG.height * 0.5}, Conductor.crochet * 0.002, {ease: FlxEase.backOut});
						FlxTween.tween(boomerRight4, {y: FlxG.height * 0.5}, Conductor.crochet * 0.002, {ease: FlxEase.backOut});
					}

					boomDanceRight = !boomDanceRight;
				}
				else
				{
					FlxTween.cancelTweensOf(boomerLeft1);
					FlxTween.cancelTweensOf(boomerLeft2);
					FlxTween.cancelTweensOf(boomerLeft3);
					FlxTween.cancelTweensOf(boomerLeft4);

					boomerLeft1.animation.curAnim.curFrame = (boomDance) ? 1 : 0;
					boomerLeft2.animation.curAnim.curFrame = (boomDance) ? 1 : 0;
					boomerLeft3.animation.curAnim.curFrame = (boomDance) ? 1 : 0;
					boomerLeft4.animation.curAnim.curFrame = (boomDance) ? 1 : 0;

					if(boomDance)
					{
						FlxTween.tween(boomerLeft1, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerLeft2, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerLeft3, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});
						FlxTween.tween(boomerLeft4, {y: FlxG.height}, Conductor.crochet * 0.002, {ease: FlxEase.backInOut});

						boomRight = true;
					}
					else
					{
						FlxTween.tween(boomerLeft1, {y: FlxG.height * 0.5}, Conductor.crochet * 0.002, {ease: FlxEase.backOut});
						FlxTween.tween(boomerLeft2, {y: FlxG.height * 0.5}, Conductor.crochet * 0.002, {ease: FlxEase.backOut});
						FlxTween.tween(boomerLeft3, {y: FlxG.height * 0.5}, Conductor.crochet * 0.002, {ease: FlxEase.backOut});
						FlxTween.tween(boomerLeft4, {y: FlxG.height * 0.5}, Conductor.crochet * 0.002, {ease: FlxEase.backOut});
					}

					boomDance = !boomDance;
				}
			}

			FlxTween.cancelTweensOf(wabe);
			wabe.screenCenter(Y);
			wabe.y += 25;
			FlxTween.tween(wabe, {y: wabe.y - 25}, Conductor.crochet * 0.004, {ease: FlxEase.expoOut});
		}
	}

	override function stepHit()
	{
		if(spawnWalk)
		{
			if(insaneSpawn)
			{
				if (FlxG.random.bool(12))
					spawnZombie();
			}
			else
			{
				if (FlxG.random.bool(1))
					spawnZombie();
			}
		}
	}

    var alreadychange:Bool = false;
	var alreadychange2:Bool = true;
    override function sectionHit()
	{
		//had to hardcode some sections cuz of STUPID ESTATICA
		if (PlayState.SONG.notes[curSection] != null && PlayState.SONG.notes[curSection].followCam && (curSection != 168 && curSection != 169 && curSection != 176 && curSection != 177 && curSection != 193 && curSection != 194))
		{
			estatica.alpha = 0.6;
			FlxTween.tween(estatica, {alpha: 0.05}, 0.5, {ease: FlxEase.quadInOut});

			if(FlxG.random.bool(1))
				game.gf.visible = true;
			else
				game.gf.visible = false;
		}

		if(PlayState.SONG.notes[curSection] != null && PlayState.SONG.notes[curSection].hwaw)
		{
			blackBarThingie.alpha = 0.3;
		}
		else
		{
			blackBarThingie.alpha = 0.00001;
			game.gf.visible = false;
		}

		if(PlayState.SONG.notes[curSection] != null)
		{
			boyfriend.visible = PlayState.SONG.notes[curSection].hwaw;
			dad.visible = PlayState.SONG.notes[curSection].pepper;
			mom.visible = PlayState.SONG.notes[curSection].pole;
			bro.visible = PlayState.SONG.notes[curSection].jack;
		}
	}

    override function opponentNoteHit(note:Note)
	{
		if(!ClientPrefs.data.lowQuality)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];
			if(!note.isSustainNote) peppers.animation.play(animToPlay, true);
			pepperHold = 0;

			if(aethosNotes && !note.isSustainNote)
				sexualHarassment(note.noteData);

			if(chroma)
				if(ClientPrefs.data.shaders && ClientPrefs.data.flashing) 
				{
					chromacrap = FlxG.random.float(0.005, 0.03);
					FlxTween.tween(this, {chromacrap: 0}, FlxG.random.float(0.05, 0.6));
				}
		}
	}

	override function goodNoteHit(note:Note)
	{
		if(!ClientPrefs.data.lowQuality)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];
			if(!note.isSustainNote) hwaws.animation.play(animToPlay, true);
			hwawHold = 0;
		}
	}

	public function sexualHarassment(intData:Int)
	{
		var noteShitties:String = notesString[Std.int(Math.abs(Math.min(notesString.length-1, intData)))];

		var notes:FlxSprite = new FlxSprite(FlxG.random.float(100, 1100), -50);
		notes.frames = Paths.getSparrowAtlas('wave4/notes');
		notes.animation.addByPrefix('idle', noteShitties, 24, true);
		notes.animation.play('idle');
		notes.antialiasing = ClientPrefs.data.antialiasing;
		notes.updateHitbox();
		notes.scrollFactor.set(0.6, 0.6);
		notes.alpha = 1;
		notesCamGroup.add(notes);

		FlxTween.tween(notes, {y: FlxG.random.float(100, 200), alpha: 0}, 1, {ease: FlxEase.expoOut,
			onComplete: function(tween:FlxTween)
			{
				notes.kill();
				notesCamGroup.remove(notes, true);
				notes.destroy();
			}
		});
	}

	public function spawnZombie(?spawnAny:Bool)
	{
		if (ClientPrefs.data.lowQuality) return;
		
		var flipShits = FlxG.random.bool(50);
		var whereToSpawn:Float = (flipShits ? 1800 : -600);

		if(spawnAny)
			whereToSpawn = FlxG.random.float(0, 1280);

		switch (FlxG.random.int(0, 4))
		{
			case 0:
				walkerZombiesFirst.add(new ZondbeWalkers(whereToSpawn, -50, flipShits));
			case 1:
				walkerZombiesSec.add(new ZondbeWalkers(whereToSpawn, 250, flipShits));
			case 2:
				walkerZombiesThird.add(new ZondbeWalkers(whereToSpawn, 450, flipShits));
			case 3:
				walkerZombiesFourth.add(new ZondbeWalkers(whereToSpawn, 650, flipShits));
			case 4:
				walkerZombiesFive.add(new ZondbeWalkers(whereToSpawn, 750, flipShits));
		}
	}

	public function spawnZombieRoof(?who:Int)
	{
		if (ClientPrefs.data.lowQuality) return;
		
		var flipShits = FlxG.random.bool(50);
		var whereToSpawn:Float = (flipShits ? 1800 : -600);

		switch (who)
		{
			case 0:
				ballons.add(new ZondbeWalkersRoof(whereToSpawn, FlxG.random.float(0, 720), flipShits, 0));
			case 1:
				walkerZombiesBox.add(new ZondbeWalkersRoof(whereToSpawn, 650, flipShits, 1));
			case 2:
				walkerZombiesDigger.add(new ZondbeWalkersRoof(whereToSpawn, 250, flipShits, 2));
			case 3:
				walkerZombiesGarg.add(new ZondbeWalkersRoof(whereToSpawn, 250, flipShits, 3));
		}
	}

	public function spawnJackson()
	{
		var flipShits = FlxG.random.bool(50);
		var whereToSpawn:Float = (flipShits ? 1300 : -20);

		jacks.add(new Jacksons(whereToSpawn, FlxG.random.float(100, 620), flipShits));
	}

	public function fallingImps()
	{
		var flipShits = FlxG.random.bool(50);
		var whereToSpawn:Float = (flipShits ? 1300 : -20);

		var imp:FlxSprite = new FlxSprite(whereToSpawn, FlxG.random.float(0, 720));
		imp.frames = Paths.getSparrowAtlas('wave3/imp');
		imp.animation.addByPrefix('idle', "imp", 24, false);
		imp.animation.play('idle');
		imp.antialiasing = ClientPrefs.data.antialiasing;
		imp.scale.set(2, 2);
		imp.updateHitbox();

		imp.velocity.x = (flipShits) ? -1380 : 1380;
		imp.flipX = !flipShits;

		impGroup.add(imp);

		imp.animation.finishCallback = function(pog:String)
		{
			imp.kill();
			impGroup.remove(imp, true);
			imp.destroy();
		}
	}

	public function goingNuts()
	{
		bgPizdec.angle = -35;
		bgPizdec.visible = true;
		FlxTween.tween(bgPizdec, {angle: 0}, 0.3, {
			ease: FlxEase.backOut,
			onComplete: function(tween:FlxTween)
			{
				new FlxTimer().start(3, function(timer:FlxTimer)
				{
					FlxTween.tween(bgPizdec.velocity, {x: 2000}, 3, {ease: FlxEase.expoIn});
				});
			}
		});
	}

    public function lofiTweensToBeCreepyTo(sprite:FlxSprite):Void //ЭТО ПИЗДЕЦ ОРИГ КОД ФОНА Я ЕБАЛ
	{
		var tempx = sprite.x;
		// this tween chain is an abomination
		// my honest reaction: https://tenor.com/ru/view/que-gif-27530657
		nesTweens.push(FlxTween.tween(sprite, {x: tempx + 420, angle: -35}, 4.0, {
			onComplete: function(tween:FlxTween)
				nesTweens.push(FlxTween.tween(sprite, {angle: 20}, 2.0, {
					onComplete: function(tween:FlxTween)
						nesTweens.push(FlxTween.tween(sprite, {x: tempx + 400, angle: 30}, 2.0, {
							onComplete: function(tween:FlxTween)
								nesTweens.push(FlxTween.tween(sprite, {x: tempx + 420, angle: 0}, 2.0, {
									onComplete: function(tween:FlxTween)
										nesTweens.push(FlxTween.tween(sprite, {x: tempx + 520, angle: -15}, 3.0, {
											onComplete: function(tween:FlxTween)
												nesTweens.push(FlxTween.tween(sprite, {angle: 10}, 1.5, {
													onComplete: function(tween:FlxTween)
														nesTweens.push(FlxTween.tween(sprite, {x: tempx - 50, angle: -40}, 5.5, {
															onComplete: function(tween:FlxTween)
																nesTweens.push(FlxTween.tween(sprite, {x: tempx, angle: 0}, 1.5))
														}))
												}))
										}))
								}))
						}))
				}))
		}));
	}
}