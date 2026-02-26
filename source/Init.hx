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

	public static var fog:Bool = true;

	override public function create():Void
	{
		super.create();

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		FlxG.save.bind('funkin', CoolUtil.getSavePath());

		Language.reloadPhrases();

		Controls.instance = new Controls();
        ClientPrefs.loadDefaultKeys();
        ClientPrefs.loadPrefs();

		Highscore.load();

		#if VIDEOS_ALLOWED
        hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0")  ['--no-lua'] #end);
        #end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 30;
		FlxG.keys.preventDefaultKeys = [TAB];

        #if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

        if(FlxG.save.data != null && FlxG.save.data.fullscreen) FlxG.fullscreen = FlxG.save.data.fullscreen;

		if (FlxG.save.data.playedSongs == null) FlxG.save.data.playedSongs = [];
		if (FlxG.save.data.playedSongsFC == null) FlxG.save.data.playedSongsFC = [];

		if (FlxG.save.data.unlockedSong == null) FlxG.save.data.unlockedSong = [];

		if (FlxG.save.data.firstTime == null) FlxG.save.data.firstTime = true;
		if (FlxG.save.data.fcUnfuck == null) FlxG.save.data.fcUnfuck = false;
		if (FlxG.save.data.fucked == null) FlxG.save.data.fucked = 0;

		if (FlxG.save.data.beatUnfuck == null) FlxG.save.data.beatUnfuck = false;
		if (FlxG.save.data.talkDevil == null) FlxG.save.data.talkDevil = false;
		if (FlxG.save.data.finalSong == null) FlxG.save.data.finalSong = false;
		if (FlxG.save.data.secretSongs == null) FlxG.save.data.secretSongs = false;
		if (FlxG.save.data.gotNote == null) FlxG.save.data.gotNote = false;
		if (FlxG.save.data.ending == null) FlxG.save.data.ending = false;

        FlxG.mouse.visible = false;

        #if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end

        // Sets the window to dark mode.
        WindowColorMode.setDarkMode();
        WindowColorMode.redrawWindowHeader(); //виндовс 11 пидарас

		Achievements.load();

		FlxG.switchState(new states.IntroState());
    }
}