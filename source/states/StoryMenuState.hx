package states;

import backend.Song;

import openfl.filters.ShaderFilter;
import openfl.filters.BlurFilter;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;

import backend.Highscore;

import shaders.VCRMario85;
import shaders.ShadersHandler;

import backend.StageData;

import options.GameplayChangersSubstate;

class StoryMenuState extends MusicBeatState
{
	var choosen = true;
	public static var curSelected:Int = 0;

	var selectorLeft:FlxText;

	var textGroup:FlxTypedGroup<FlxText>;
	var songs:Array<String> = [ //это явно можно было сделать по умному нооо это я :3
		'UNFUCKABLE',
		'UNFUCKABLE',
		'UNFUCKABLE',
		'UNFUCKABLE',
		'UNFUCKABLE',
		'UNFUCKABLE',
		'UNFUCKABLE',
		'UNFUCKABLE',
		'UNFUCKABLE',
		'UNFUCKABLE',
		'UNFUCKABLE',
		'UNFUCKABLE'
	];

	var curDiff:Int = 0;

	var handShaders:Array<NTSCGlitch> = [];

	var yPosy:Float = 0;
	var bg:FlxSprite;
	var portrait:FlxSprite;
	public var vcr:VCRMario85;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;
		PlayState.isStoryMode = true;

		bg = new FlxSprite().loadGraphic(Paths.image('bgFake'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		portrait = new FlxSprite();
		portrait.loadGraphic(Paths.image('everyone'));
		portrait.antialiasing = false;
		portrait.setPosition(750, 150);
		portrait.scale.set(1.2, 1.2);
		portrait.updateHitbox();
		portrait.scrollFactor.set();
		portrait.offset.set(-190, 110);
		handShaders.push(cast portrait.shader = new NTSCGlitch(0.2));
		add(portrait);

		FlxTween.tween(portrait, {x: 550}, 1, {ease: FlxEase.quadOut});

		if(FlxG.save.data.fcUnfuck == true)
		{
			var fcTrophy = new FlxSprite(524, 438).loadGraphic(Paths.image('fcAchieve'));
			fcTrophy.antialiasing = false;
			add(fcTrophy);
		}

		selectorLeft = new FlxText(0, 0, 0, '>');
		selectorLeft.setFormat(Paths.font("mariones.ttf"), 24, FlxColor.WHITE);
		selectorLeft.visible = false;
		add(selectorLeft);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("ACCEPT YOUR FATE", null);
		#end

		FlxG.camera.bgColor = 0xFF000000; //пизда

		Difficulty.resetList();
		curDiff = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(Highscore.getRating('UNFUCKABLE', curDiff) * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}

		var scores:FlxText = new FlxText(0, FlxG.height - 44, 0,'', 12);
		scores.text = 'PERSONAL BEST: ' + Highscore.getScore('UNFUCKABLE', curDiff) + ' (' + ratingSplit.join('.') + '%)';
		scores.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scores);
		scores.screenCenter(X);

		textGroup = new FlxTypedGroup<FlxText>();
		add(textGroup);

		new FlxTimer().start(0.08, function(tmr:FlxTimer)
		{
			var item:FlxText = createMenuItem('UNFUCKABLE', 150, (yPosy * 50) + 100);
			yPosy += 1;
		}, songs.length);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			choosen = false;
			changeSong();
		});

		vcr = new VCRMario85();

		super.create();

		if(ClientPrefs.data.tvEffect)
		{
			FlxG.camera.setFilters([ShadersHandler.chromaticAberration, ShadersHandler.radialBlur, new ShaderFilter(vcr)]);
			ShadersHandler.setChrome(0);
		}
	}

	override function update(elapsed:Float)
	{
		if (!choosen)
		{
			if (controls.UI_UP_P)
			{
				changeSong(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_DOWN_P)
			{
				changeSong(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.ACCEPT)
			{
				Init.fun = FlxG.random.int(0, 100);
				//Init.fun = 100;

				choosen = true;
				var selectedItem:FlxText;
				selectedItem = textGroup.members[curSelected];
				
				for (i in 0...textGroup.length)
				{
					textGroup.members[i].visible = false;
				}

				selectedItem.visible = true;
				FlxG.sound.music.volume = 0;
				bg.visible = portrait.visible = false;

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxG.camera.flash(FlxColor.BLACK, 999); //like what else, better than creating whole graphic
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						PlayState.storyPlaylist = ['unfuckable'];
						PlayState.isStoryMode = true;
				
						Init.fog = false;
				
						Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '', PlayState.storyPlaylist[0].toLowerCase());
				
						start();
					});
				});
			}
		}

		if (controls.BACK && !choosen)
		{
			choosen = true;
			FlxTween.tween(FlxG.sound.music, {pitch: 1}, 0.5);
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		for (shader in handShaders)
		{
			shader.time.value = [elapsed];
			shader.setGlitch(FlxG.random.float(1, 25));
		}

		if(ClientPrefs.data.tvEffect)
		{
			vcr.update(elapsed);
			ShadersHandler.setChrome(FlxG.random.int(2,6)/1000);
			ShadersHandler.setRadialBlur(640, 360,  FlxG.random.float(0.001, 0.01));
		}
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function start()
	{
		if(Init.fun >= 25 && Init.fun <= 42)
		{
			MusicBeatState.switchState(new cutscenes.CutsceneState());
		}
		else
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
				
			if(!ClientPrefs.data.optimize) LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
		}

		FlxG.sound.music.stop();
	}

	function changeSong(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected >= 11)
			curSelected = 11;
		if (curSelected < 0)
			curSelected = 0;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		var selectedItem:FlxText;
		selectedItem = textGroup.members[curSelected];
		selectorLeft.visible = true;
		selectorLeft.x = selectedItem.x - 63;
		selectorLeft.y = selectedItem.y;
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxText
	{
		var menuItem:FlxText = new FlxText(x, y, 0);
		menuItem.text = name;
		menuItem.setFormat(Paths.font("mariones.ttf"), 24, FlxColor.WHITE, LEFT);
		textGroup.add(menuItem);
		return menuItem;
	}
}

class NTSCGlitch extends FlxShader // stolen from that one popular vhs shader used in ourple guy criminal
{
	@:glFragmentSource('
     #pragma header

    uniform float time;
    uniform vec2 resolution;

    uniform float glitchAmount;

    #define PI 3.14159265

    vec4 tex2D( sampler2D _tex, vec2 _p ){
        vec4 col = texture2D( _tex, _p );
        if ( 0.5 < abs( _p.x - 0.5 ) ) {
            col = vec4( 0.1 );
        }
        return col;
    }

    float hash( vec2 _v ){
        return fract( sin( dot( _v, vec2( 89.44, 19.36 ) ) ) * 22189.22 );
    }

    float iHash( vec2 _v, vec2 _r ){
        float h00 = hash( vec2( floor( _v * _r + vec2( 0.0, 0.0 ) ) / _r ) );
        float h10 = hash( vec2( floor( _v * _r + vec2( 1.0, 0.0 ) ) / _r ) );
        float h01 = hash( vec2( floor( _v * _r + vec2( 0.0, 1.0 ) ) / _r ) );
        float h11 = hash( vec2( floor( _v * _r + vec2( 1.0, 1.0 ) ) / _r ) );
        vec2 ip = vec2( smoothstep( vec2( 0.0, 0.0 ), vec2( 1.0, 1.0 ), mod( _v*_r, 1. ) ) );
        return ( h00 * ( 1. - ip.x ) + h10 * ip.x ) * ( 1. - ip.y ) + ( h01 * ( 1. - ip.x ) + h11 * ip.x ) * ip.y;
    }

    float noise( vec2 _v ){
        float sum = 0.;
        for( int i=1; i<9; i++ )
        {
            sum += iHash( _v + vec2( i ), vec2( 2. * pow( 2., float( i ) ) ) ) / pow( 2., float( i ) );
        }
        return sum;
    }

    void main(){
        vec2 uvn = openfl_TextureCoordv.xy;

        // tape wave
        uvn.x += ( noise( vec2( uvn.y, time ) ) - 0.5 )* 0.002;
        uvn.x += ( noise( vec2( uvn.y * 100.0, time * 10.0 ) ) - 0.5 ) * (0.01*glitchAmount);

        vec4 col = tex2D( bitmap, uvn );

        col *= 1.0 + clamp( noise( vec2( 0.0, uvn.y + time * 0.2 ) ) * 0.6 - 0.25, 0.0, 0.1 );

        gl_FragColor = col;
    }
    ')
	public override function new(?_glitch:Float = 2)
	{
		super();

		time.value = [0];
		resolution.value = [FlxG.width, FlxG.height];

		setGlitch(_glitch);
	}

	public inline function setGlitch(?amount:Float = 0)
	{
		glitchAmount.value = [amount];
	}

	public inline function update(elapsed:Float)
	{
		time.value[0] += elapsed;
	}
}