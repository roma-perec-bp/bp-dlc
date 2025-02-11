package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

import backend.WeekData;
import backend.Highscore;

import states.StoryMenuState;
import states.FlashingState;

import hxwindowmode.WindowColorMode;

class Init extends FlxState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var fun:Int;
	public static var fog:Bool = true;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        FlxG.save.bind('funkin', CoolUtil.getSavePath());

        Highscore.load();

        FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

        #if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

        Language.reloadPhrases();
        ClientPrefs.loadPrefs();

        if(FlxG.save.data != null && FlxG.save.data.fullscreen) FlxG.fullscreen = FlxG.save.data.fullscreen;

		if (FlxG.save.data.firstTime == null) FlxG.save.data.firstTime = true;
		if (FlxG.save.data.fcUnfuck == null) FlxG.save.data.fcUnfuck = false;
		if (FlxG.save.data.fucked == null) FlxG.save.data.fucked = 0;

        FlxG.mouse.visible = false;

        super.create();

        #if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end
        
		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0")  ['--no-lua'] #end);
		#end

        // Sets the window to dark mode.
        WindowColorMode.setDarkMode();
        WindowColorMode.redrawWindowHeader(); //виндовс 11 пидарас

		FlxG.switchState(new states.IntroState());
    }
}