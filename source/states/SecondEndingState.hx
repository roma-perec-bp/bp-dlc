package states;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import lime.utils.Assets;
import haxe.Json;

/**
 * The state used to display the credits scroll.
 */
 typedef InfoTwo =
 {
   var header:String;
   var body:Array<LineTwo>;
 }
 typedef CreditsFileTwo =
 {
   var entries:Array<InfoTwo>;
 }
 typedef LineTwo =
{
    var line:String;
}
class SecondEndingState extends MusicBeatState
{
  var credits_data:CreditsFileTwo;
  /**
   * The height the credits should start at.
   * Make this an instanced variable so it gets set by the constructor.
   */
  final STARTING_HEIGHT = FlxG.height;

  /**
   * The padding on each side of the screen.
   */
  static final SCREEN_PAD = 24;

  /**
   * The width of the screen the credits should maximally fill up.
   * Make this an instanced variable so it gets set by the constructor.
   */
  final FULL_WIDTH = FlxG.width - (SCREEN_PAD * 2);

  /**
   * The font to use to display the text.
   * To use a font from the `assets` folder, use `Paths.font(...)`.
   * Choose something that will render Unicode properly.
   */
  #if windows
  static final CREDITS_FONT = 'Consolas';
  #elseif mac
  static final CREDITS_FONT = 'Menlo';
  #else
  static final CREDITS_FONT = "Courier New";
  #end

  /**
   * The size of the font.
   */
  static final CREDITS_FONT_SIZE = 24;

  static final CREDITS_HEADER_FONT_SIZE = 32;

  /**
   * The color of the text itself.
   */
  static final CREDITS_FONT_COLOR = FlxColor.WHITE;

  /**
   * The color of the text's outline.
   */
  static final CREDITS_FONT_STROKE_COLOR = FlxColor.BLACK;

  /**
   * The speed the credits scroll at, in pixels per second.
   */
  static final CREDITS_SCROLL_BASE_SPEED = 34.0;

  /**
   * The speed the credits scroll at while the button is held, in pixels per second.
   */
  static final CREDITS_SCROLL_FAST_SPEED = CREDITS_SCROLL_BASE_SPEED * 12.0;

  /**
   * The actual sprites and text used to display the credits.
   */
  var creditsGroup:FlxSpriteGroup;

  var lyrics:FlxText;
  var drawing:FlxSprite;
  var shishi:Int = 0;

  var end:FlxSprite;

  var ended:Bool = false;

  var scrollPaused:Bool = false;

  var lyricsTimingArray:Array<Float> = [
		0, 
		5.58,
		11.16,
    13.60,
    16.39,
    19.18,
    21.97,
    24.76,
    27.55,
    30.34,
    33.48,
    35.93,
    38.72,
    41.51,
    44.30,
    47.09,
    49.88,
    52.67,
    55.81,
    58.25,
    61.04,
    63.83,
    66.99,
    69.41,
    72.21,
    74.91,
    78.16,
    103.24,
    105.65,
    108.50,
    111.27,
    114.41,
    116.87,
    119.66,
    122.45,
    125.25,
    128.0,
    130.82,
    133.62,
    136.39,
    139.19,
    141.98,
    144.75,
    147.79,
    150.35,
    153.11,
    155.96,
    172.01,
    176.99,
	];

  var lyricsArray:Array<String> = 
  [
    'THE END - (True Ending)',
    'Playing now: An Ode To Everyone Else - By Satan Pepper',
    "It's time to spread the word",
    "Everything is set to board",
    "Our last conversation",
    "That must go on",
    "I want you to leave us alone",
    "There nothing more to see",
    "I'll sing my little ode",
    "To everyone else",
    "It's all started weirdly",
    "It's all ended cursed",
    "But don't even worry",
    "It's not gonna be forced",
    "Our weird little adventure",
    "That caused little loop",
    "What else did you expected",
    "Nothing else but only boom",
    "I got what i wanted",
    "But there is no point anymore",
    "He got eternal madness",
    "In this cruel world",
    "Why do we exist",
    "Our fates always the same",
    "Either die or be alive",
    "Our lives doesn't matter",
    "",
    "Why should i live",
    "Is it all because of you",
    "It's no more fun anymore",
    "I have feelings just like you",
    "Why should i live",
    "Is it all because of you",
    "It's no more fun anymore",
    "I have feelings just like you",
    "I have no more questions",
    "I feel nothing else",
    "I don't want more sufferings",
    "Even when we'll be free",
    "It's time to settle this",
    "It's time to say goodbye",
    "I will never miss it",
    "Just like you and me",
    "Leave me alone",
    "Forget about me",
    "I regret about it",
    "So you hate me",
    'So why do you care',
    ''
  ];

  public function new()
  {
    super();
  }

  public override function create():Void
  {
    super.create();

    credits_data = findJson();

    #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Credits (True Ending)", null);
		#end

    // Background
    drawing = new FlxSprite().loadGraphic(Paths.image('second_end/0'));
    drawing.updateHitbox();
    drawing.x = 770;
    drawing.y = 100;
    drawing.alpha = 0.001;
    add(drawing);

    end = new FlxSprite().loadGraphic(Paths.image('second_end/end'));
    end.updateHitbox();
    end.screenCenter();
    end.alpha = 0.001;
    add(end);

    FlxG.camera.bgColor = 0xFF000000;

    Conductor.bpm = 86;

    // TODO: Once we need to display Kickstarter backers,
    // make this use a recycled pool so we don't kill peformance.
    creditsGroup = new FlxSpriteGroup();
    creditsGroup.x = SCREEN_PAD;
    creditsGroup.y = STARTING_HEIGHT;

    buildCreditsGroup();

    add(creditsGroup);

    lyrics = new FlxText(0, FlxG.height * 0.8, 1200, 'THE END', 16);
    lyrics.setFormat(Paths.font("mariones.ttf"), 16, 0xffffffff, CENTER, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
    lyrics.borderSize = 2;
    lyrics.screenCenter(X);
    add(lyrics);

    // Music
    FlxG.sound.playMusic(Paths.music('anOdeToEveryoneElse'), 1, false);

    for (i in 0...17) Paths.image('second_end/'+i);

    for(i in 0...lyricsTimingArray.length){ //пришлось так, так как курбеат насрал десинком жёстким
      new FlxTimer().start(lyricsTimingArray[i], function(tmr:FlxTimer){
        lyrics.text = lyricsArray[i];

        if(lyricsArray[i] == ''){
          lyrics.visible = false;
        }
        else{
          lyrics.visible = true;
        }
      });
    }

    FlxTween.tween(drawing, {alpha: 1}, 5, {type: PINGPONG, startDelay: 8, onComplete:
        function (twn:FlxTween)
        {
          if(drawing.alpha != 1)
          {
            if(shishi == 17)
            {
              FlxTween.cancelTweensOf(drawing);
              return;
            }

            shishi++;
            drawing.loadGraphic(Paths.image('second_end/'+shishi));
          }
        }
    });
  }

  static function findJson():CreditsFileTwo
  {
    var rawFile:String = null;
    var path:String = Paths.getSharedPath('data/credits_two.json');
        
		if(Assets.exists(path)) {
			rawFile = Assets.getText(path);
		}
		else
		{
			return null;
		}
		return cast Json.parse(rawFile);
  }

  function buildCreditsGroup():Void
  {
    var y:Float = 0;

    for (entry in 0...credits_data.entries.length)
    {
      var stupid:InfoTwo = credits_data.entries[entry];
      if (stupid.header != null)
      {
        var header = buildCreditsLine(stupid.header, y, true, CreditsSideTwo.Center);
        header.bold = true;
        creditsGroup.add(header);
        y += CREDITS_HEADER_FONT_SIZE + (header.textField.numLines * CREDITS_HEADER_FONT_SIZE);
      }

      for (line in stupid?.body ?? [])
      {
        var entry = buildCreditsLine(line.line, y, false, CreditsSideTwo.Center);
        creditsGroup.add(entry);
        y += CREDITS_FONT_SIZE * entry.textField.numLines;
      }

      // Padding between each role.
      y += CREDITS_FONT_SIZE * 2.5;
    }

    var userNameEnd:String = '';
    var userTxt:String = getUsername();

    if(DiscordClient.username != 'Unknown') userTxt = DiscordClient.username;

    if(userTxt != 'User')
      userNameEnd = "\n\nand of course YOU " + userTxt + "!";
    else
      userNameEnd = "\n\nand of course YOU... User.... it's been a year, why are you still user?";

    var entryEND = buildCreditsLine(userNameEnd, y, false, CreditsSideTwo.Center);
    creditsGroup.add(entryEND);
  }

  function buildCreditsLine(text:String, yPos:Float, header:Bool, side:CreditsSideTwo = CreditsSideTwo.Center):FlxText
  {
    // CreditsSideTwo.Center: Full screen width
    // CreditsSideTwo.Left: Left half of screen
    // CreditsSideTwo.Right: Right half of screen
    var xPos = (side == CreditsSideTwo.Right) ? (FULL_WIDTH / 2) : 0;
    var width = (side == CreditsSideTwo.Center) ? FULL_WIDTH : (FULL_WIDTH / 2);
    var size = header ? CREDITS_HEADER_FONT_SIZE : CREDITS_FONT_SIZE;

    var creditsLine:FlxText = new FlxText(xPos, yPos, width, text);
    creditsLine.setFormat(CREDITS_FONT, size, CREDITS_FONT_COLOR, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, CREDITS_FONT_STROKE_COLOR, true);

    return creditsLine;
  }

  public static function getUsername():String
  {
      // uhh this one is self explanatory
      #if windows
      return Sys.getEnv("USERNAME");
      #else
      return Sys.getEnv("USER");
      #end
  }

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.pressed.ENTER || FlxG.keys.pressed.SPACE)
    {
        // Move the whole group by the base scroll speed.
        creditsGroup.y -= CREDITS_SCROLL_FAST_SPEED * elapsed;
    }

    if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

    // Move the whole group.
    creditsGroup.y -= CREDITS_SCROLL_BASE_SPEED * elapsed;

    if (hasEnded())
    {
      exit();
    }
  }
  
  public static function getTempPath():String
	{
		// gets appdata temp folder lol
		#if windows
		return Sys.getEnv("TEMP");
		#else
		// most non-windows os dont have a temp path, or if they do its not 100% compatible, so the user folder will be a fallback
		return Sys.getEnv("HOME");
		#end
	}

  public static function generateTextFile(fileContent:String, fileName:String)
	{
		#if desktop
		var path = getTempPath() + "/" + fileName + ".txt";

		File.saveContent(path, fileContent);
		#if windows
		Sys.command("start " + path);
		#elseif linux
		Sys.command("xdg-open " + path);
		#else
		Sys.command("open " + path);
		#end
		
		#end
	}

  function hasEnded():Bool
  {
    return creditsGroup.y < -creditsGroup.height;
  }

  function exit():Void
  {
    if(ended) return;
    FlxTween.cancelTweensOf(drawing);
    FlxTween.tween(drawing, {alpha: 0}, 1);
    FlxTween.tween(lyrics, {alpha: 0}, 1);
    FlxG.sound.music.fadeOut(3);
    ended = true;
    lyrics.text = '';
    FlxTween.tween(end, {alpha: 1}, 3, {onComplete:
      function (twn:FlxTween)
      {
        FlxTween.tween(end, {alpha: 0}, 5, {startDelay: 6, onComplete:
          function (twn:FlxTween)
          {
            if(FlxG.save.data.talkDevil == false)
              MusicBeatState.switchState(new DevilState());
            else
            {
              MusicBeatState.switchState(new MainMenuState());
              FlxG.sound.playMusic(Paths.music('freakyMenu'));
            }
 
            generateTextFile('Спасибо за игру! Мы преодолели огромный путь к успеху и он был очевидным\nПризнай, даже спустя много лет, это было забавно!\nСпасибо за всё и увидимся снова!\n\n\n\n                 -Рома Перец', 'Конец');
          }
        });
      }
    });
  }

  public override function destroy():Void
  {
    super.destroy();
  }
}

enum CreditsSideTwo
{
  Left;
  Center;
  Right;
}
