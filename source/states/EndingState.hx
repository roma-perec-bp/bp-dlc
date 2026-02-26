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
 typedef Info =
 {
   var header:String;
   var body:Array<Line>;
 }
 typedef CreditsFile =
 {
   var entries:Array<Info>;
 }
 typedef Line =
{
    var line:String;
}
class EndingState extends MusicBeatState
{
  var credits_data:CreditsFile;
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
  static final CREDITS_SCROLL_BASE_SPEED = 29.0;

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
		5.64,
		11.29,
		14.11,
		16.94,
		19.76,
		22.58,
		25.41,
		28.23,
		31.05,
		33.88,
		36.70,
		39.52,
		42.35,
		45.17, 
		48,
		50.82, 
		53.64, 
		56.47, 
		57.88, 
		59.29,   
		60.70,   
		62.11, 
		63.53,
		64.94, 
		66.35,
		67.76,
		69.17, 
		70.59,
		72,
		73.41,
		74.82,
		76.24,
		77.65,
		79.06,
		81.88,
		84.71,
		87.53,
		90.35,
		93.18,
		96,
		98.82,
    101.65, 
		104.47, 
		107.29, 
		110.12, 
		112.94,   
		124.24,   
		127.06, 
		129.88,
		132.71, 
    134.12, 
		135.53,
		136.94,
		138.35, 
		139.76,
		141.18,
		142.59,
		144,
		145.41,
		146.82,
		148.24,
		149.65,
		151.06,
		152.47,
		153.88,
		155.29,
		156.71,
    158.12,
		160.59,
    163.42,
    166.25,
    169.41,
    171.89,
    174.71,
    177.53,
    180.71,
    183.53,
    186.35,
    189.18,
    192,
    194.82,
    197.65,
    200.47,
    203.29,
	];

  var lyricsArray:Array<String> = 
  [
    'THE END - (Main Ending)',
    'Playing now: FuckYo - By ROMA PEREC',
    'Как же жарко, да и ярко',
    'Но в итоге всё пропало',
    'Сжёг он грядки, вот беспорядки',
    'Да и ладно, все мы то в порядке',
    'А ведь HWAW то, плохой парень',
    'Выйдя с Ютуба его похвалим',
    'Что за бред то я несу ведь',
    'Он не прошёл, я пососу',
    'Мы все давно уже мертвы',
    'Всё это сон где есть и ты!',
    'В чём же цель? Хороший вопрос!',
    'Только не суй везде свой нос',
    'Это всё, наступил конец',
    'Брутал EX победил же всех',
    'Эх ты Аггей... Не отстанет же он',
    'Это твоя вина гандон',
    'Иди нахуй, ты бездарность',
    'Ведь ты знаешь он опасность',
    'Смерть придет, конец устроит',
    'И хуйню там наворотит',
    'Иди нахуй, ты бездарность',
    'Ведь ты знаешь он опасность',
    'В жопу игры ведь умрешь ты',
    'И в аду дадут пизды!',
    'Иди нахуй, ты бездарность',
    'Ведь ты знаешь он опасность',
    'Смерть придет, конец устроит',
    'И хуйню там наворотит',
    'Иди нахуй, ты бездарность',
    'Ведь ты знаешь он опасность',
    'В жопу игры ведь умрешь ты',
    'И в аду дадут пизды!',
    'Бесполезный кусок дерьма',
    'Чекай чё могу я',
    'Ты не пройдешь, ты пососешь',
    'Ты не то читаешь, перелестни там дальше',
    'Вот настал конец игре',
    'Гибриды обосрались в огне',
    'Утонув в Зомбиаквариуме',
    'И деменция пиздит по голове',
    'Умбра умер или нет',
    'Рандом шорт, знает ответ',
    'ЧТО ЗА БРЕД, МЫ НЕСЁМ ВСЕ',
    'РОМА ЭТО ЧТО ТАКОЕ???',
    '(фнф момент)',
    'Несмотря на все обиды',
    'Перец сжёг тут всё до пизды',
    'И тебе, скажу одно',
    'ЖИВИ ЖИЗНЬЮ',
    'ВОТ И ВСЁ!',
    'Иди нахуй, ты бездарность',
    'Ведь ты знаешь он опасность',
    'Смерть придет, конец устроит',
    'И хуйню там наворотит',
    'Иди нахуй, ты бездарность',
    'Ведь ты знаешь он опасность',
    'В жопу игры ведь умрешь ты',
    'И в аду дадут пизды!',
    'Иди нахуй, ты бездарность',
    'Ведь ты знаешь он опасность',
    'Смерть придет, конец устроит',
    'И хуйню там наворотит',
    'Иди нахуй, ты бездарность',
    'Ведь ты знаешь он опасность',
    'В жопу игры ведь умрешь ты',
    'И в аду дадут пизды!',
    'ЛУЧШЕ БЫ ТЕБЕ УЙТИ!',
    'ВЕДЬ ТЫ ИДЕШЬ НЕ ПО ПУТИ!',
    'ОТСОСЁШЬ КОНЦЫ К КОНЦАМ!',
    'ВЕДЬ ОН НЕ АГГЕЙ ДЛЯ ВСЕХ ВАС!',
    'ЛУЧШЕ БЫ ТЕБЕ УЙТИ!',
    'ВЕДЬ ТЫ ИДЕШЬ НЕ ПО ПУТИ!',
    'ОТСОСЁШЬ КОНЦЫ К КОНЦАМ!',
    'ВЕДЬ ОН НЕ АГГЕЙ ДЛЯ ВСЕХ ВАС!',
    'Как же жарко, да и ярко',
    'Но в итоге всё пропало',
    'Сжёг он грядки, вот беспорядки',
    'Да и ладно, все мы то в порядке',
    'Несмотря на все обиды',
    'Перец сжёг тут всё до пизды',
    'И тебе, скажу одно',
    'Прощай, спасибо за всё',
    '',
  ];

  var him:Bool = false;

  public function new()
  {
    super();
  }

  public override function create():Void
  {
    super.create();

    #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Credits (Main Ending)", null);
		#end

    credits_data = findJson();

    // Background
    drawing = new FlxSprite().loadGraphic(Paths.image('ending/0'));
    drawing.updateHitbox();
    drawing.x = 770;
    drawing.y = 100;
    drawing.alpha = 0.001;
    add(drawing);

    end = new FlxSprite().loadGraphic(Paths.image('ending/end'));
    end.updateHitbox();
    end.screenCenter();
    end.alpha = 0.001;
    add(end);

    FlxG.camera.bgColor = 0xFF000000;

    Conductor.bpm = 170;

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
    FlxG.sound.playMusic(Paths.music('fuckYo'), 1, false);

    for (i in 0...16) Paths.image('ending/'+i);

    if(FlxG.random.bool(6)) him = true;

    if(him) Paths.image('ending/10x'); //FUN VALUE MOMENT

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

    FlxTween.tween(drawing, {alpha: 1}, 5, {type: PINGPONG, startDelay: 10, onComplete:
        function (twn:FlxTween)
        {
          if(drawing.alpha != 1)
          {
            if(shishi == 16)
            {
              FlxTween.cancelTweensOf(drawing);
              return;
            }

            shishi++;
            if(shishi == 10)
            {
              if(him)
                drawing.loadGraphic(Paths.image('ending/'+shishi+'x', 'embed'));
              else
                drawing.loadGraphic(Paths.image('ending/'+shishi));
            }
            else
            {
              drawing.loadGraphic(Paths.image('ending/'+shishi));
            }
          }
        }
    });
  }

  static function findJson():CreditsFile
  {
    var rawFile:String = null;
    var path:String = Paths.getSharedPath('data/credits.json');
        
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
      var stupid:Info = credits_data.entries[entry];
      if (stupid.header != null)
      {
        var header = buildCreditsLine(stupid.header, y, true, CreditsSide.Center);
        header.bold = true;
        creditsGroup.add(header);
        y += CREDITS_HEADER_FONT_SIZE + (header.textField.numLines * CREDITS_HEADER_FONT_SIZE);
      }

      for (line in stupid?.body ?? [])
      {
        var entry = buildCreditsLine(line.line, y, false, CreditsSide.Center);
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
      userNameEnd = "\n\nand of course YOU... User.... seriously?";

    var entryEND = buildCreditsLine(userNameEnd, y, false, CreditsSide.Center);
    creditsGroup.add(entryEND);
  }

  function buildCreditsLine(text:String, yPos:Float, header:Bool, side:CreditsSide = CreditsSide.Center):FlxText
  {
    // CreditsSide.Center: Full screen width
    // CreditsSide.Left: Left half of screen
    // CreditsSide.Right: Right half of screen
    var xPos = (side == CreditsSide.Right) ? (FULL_WIDTH / 2) : 0;
    var width = (side == CreditsSide.Center) ? FULL_WIDTH : (FULL_WIDTH / 2);
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
 
            //generateTextFile('Хорошая игра была не так ли? Надеюсь больше не встретимся ХВАВ, ты меня уже заебал         -Зомби Перцы', 'GG');
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

enum CreditsSide
{
  Left;
  Center;
  Right;
}
