package backend;

#if ACHIEVEMENTS_ALLOWED
import objects.AchievementPopup;
import haxe.Exception;
import haxe.Json;

#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

import states.GetALifeState;

typedef Achievement =
{
	var name:String;
	var description:String;
	@:optional var hidden:Bool;
	@:optional var maxScore:Float;
	@:optional var maxDecimals:Int;

	//handled automatically, ignore these two
	@:optional var mod:String;
	@:optional var ID:Int; 
}

enum abstract AchievementOp(String)
{
	var GET = 'get';
	var SET = 'set';
	var ADD = 'add';
}

class Achievements {
	public static function init()
	{
		createAchievement('friday_night_play',		{name: "Get Freaky on a Friday Night!", description: "Play on a Friday... Night.", hidden: false});
		createAchievement('unfuckable_beat',		{name: "Unbeatable", description: "Beat UNFUCKABLE song.", hidden: false});
		createAchievement('unfuckable_lose',		{name: "YOU CANNOT FUCK US", description: "Die on UNFUCKABLE song.", hidden: false});
		createAchievement('unfuckable_nodeaths',	{name: "UNFUCKABLE", description: "Beat UNFUCKABLE song with no deaths and without watching any ads.", hidden: false});
		createAchievement('unfuckable_nomiss',		{name: "INVINCIBLE", description: "Beat UNFUCKABLE song with no misses.", hidden: false});
		createAchievement('unfuckable_finalwave',	{name: "Awww you almost got it!", description: "In UNFUCKABLE song, die on the Final Wave.", hidden: false});
		createAchievement('unfuckable_dontmiss',	{name: "I said don't miss!", description: "In UNFUCKABLE song, miss on DON'T miss part.", hidden: false});
		createAchievement('death_insta',			{name: "LOOK OUT", description: "Get killed by insta-pepper note.", hidden: true});
		createAchievement('exerection_nomiss',		{name: "The first one", description: "Beat Exerection song with no misses.", hidden: true});
		createAchievement('rookie_nomiss',			{name: "Still Not Better than MM v2", description: "Beat Rokkie week with no misses.", hidden: true});
		createAchievement('dep_nomiss',				{name: "Who the fuck are you", description: "Beat D.E.P song with no misses.", hidden: true});
		createAchievement('dep_lose',				{name: "P.R.O.E.B.A.L", description: "Die on D.E.P song.", hidden: true});
		createAchievement('caramelldansen_nomiss',	{name: "Dance my little pepperlings!", description: "Beat CaramellDansen song with no misses.", hidden: true});
		createAchievement('caramelldansen_chart',	{name: "You think it's funny?!", description: "Try to access Chart Editor in CaramellDansen song.", hidden: true});
		createAchievement('hard-mode_lose',			{name: "Evil Nene", description: "Die on Hard Mode song.", hidden: true});
		createAchievement('hard-mode_nomiss',		{name: "Long time no see", description: "Beat Hard Mode song with no misses.", hidden: true});
		createAchievement('secretsongs',			{name: "Thanks for collecting my songs", description: "Find and beat all secret songs.", hidden: true});
		createAchievement('holy-hell_beat',			{name: "That was fun", description: "Beat Holy Hell song and end this for good!", hidden: true});
		createAchievement('holy-hell_hard',			{name: "Absolute Devil", description: "Beat Holy Hell song on HARD difficulty", hidden: true});
		createAchievement('holy-hell_lose',			{name: "Does it feels familiar?", description: "Die on Holy Hell song.", hidden: true});
		createAchievement('end',					{name: "Thank you for playing!", description: "Complete the mod.", hidden: true});
		createAchievement('chart',					{name: "You're cheating!", description: "Try to access the chart editor.", hidden: false});
		createAchievement('pizdec',					{name: "Why r u still here lol", description: "Make secret chart editor song play 6 times.", hidden: false});
		createAchievement('cum',					{name: "Unfunny Cum Joke", description: "beat a song with all white colored colors on notes.", hidden: false});
		createAchievement('downscroll',				{name: "Are you happy now?", description: "beat a song with downscroll or middlescroll enabled.", hidden: false});
		createAchievement('onehundrec',				{name: "Holy fuck i'm cumming...", description: "100% this fucking mod and prove me that you have no life...", hidden: false});

		//dont delete this thing below
		_originalLength = _sortID + 1;
	}

	public static var achievements:Map<String, Achievement> = new Map<String, Achievement>();
	public static var variables:Map<String, Float> = [];
	public static var achievementsUnlocked:Array<String> = [];
	private static var _firstLoad:Bool = true;

	public static function get(name:String):Achievement
		return achievements.get(name);
	public static function exists(name:String):Bool
		return achievements.exists(name);

	public static function load():Void
	{
		if(!_firstLoad) return;

		if(_originalLength < 0) init();

		if(FlxG.save.data != null) {
			if(FlxG.save.data.achievementsUnlocked != null)
				achievementsUnlocked = FlxG.save.data.achievementsUnlocked;

			var savedMap:Map<String, Float> = cast FlxG.save.data.achievementsVariables;
			if(savedMap != null)
			{
				for (key => value in savedMap)
				{
					variables.set(key, value);
				}
			}
			_firstLoad = false;
		}
	}

	public static function save():Void
	{
		FlxG.save.data.achievementsUnlocked = achievementsUnlocked;
		FlxG.save.data.achievementsVariables = variables;
	}
	
	public static function getScore(name:String):Float
		return _scoreFunc(name, GET);

	public static function setScore(name:String, value:Float, saveIfNotUnlocked:Bool = true):Float
		return _scoreFunc(name, SET, value, saveIfNotUnlocked);

	public static function addScore(name:String, value:Float = 1, saveIfNotUnlocked:Bool = true):Float
		return _scoreFunc(name, ADD, value, saveIfNotUnlocked);

	static function _scoreFunc(name:String, mode:AchievementOp, addOrSet:Float = 1, saveIfNotUnlocked:Bool = true):Float
	{
		if(!variables.exists(name))
			variables.set(name, 0);

		if(achievements.exists(name))
		{
			var achievement:Achievement = achievements.get(name);
			if(achievement.maxScore < 1) throw new Exception('Achievement has score disabled or is incorrectly configured: $name');

			if(achievementsUnlocked.contains(name)) return achievement.maxScore;

			var val = addOrSet;
			switch(mode)
			{
				case GET: return variables.get(name); //get
				case ADD: val += variables.get(name); //add
				default:
			}

			if(val >= achievement.maxScore)
			{
				unlock(name);
				val = achievement.maxScore;
			}
			variables.set(name, val);

			Achievements.save();
			if(saveIfNotUnlocked || val >= achievement.maxScore) FlxG.save.flush();
			return val;
		}
		return -1;
	}

	static var _lastUnlock:Int = -999;
	public static function unlock(name:String, autoStartPopup:Bool = true, soundDo:Bool = true):String {
		if(!achievements.exists(name))
		{
			FlxG.log.error('Achievement "$name" does not exists!');
			throw new Exception('Achievement "$name" does not exists!');
			return null;
		}

		if(Achievements.isUnlocked(name)) return null;

		trace('Completed achievement "$name"');
		achievementsUnlocked.push(name);

		// earrape prevention
		var time:Int = openfl.Lib.getTimer();
		if(Math.abs(time - _lastUnlock) >= 100) //If last unlocked happened in less than 100 ms (0.1s) ago, then don't play sound
		{
			if(soundDo) FlxG.sound.play(Paths.sound('confirmAch'), 0.5);
			_lastUnlock = time;
		}

		Achievements.save();
		FlxG.save.flush();

		if(autoStartPopup) startPopup(name);

		return name;
	}

	inline public static function isUnlocked(name:String)
		return achievementsUnlocked.contains(name);

	@:allow(objects.AchievementPopup)
	private static var _popups:Array<AchievementPopup> = [];

	public static var showingPopups(get, never):Bool;
	public static function get_showingPopups()
		return _popups.length > 0;

	public static function startPopup(achieve:String, endFunc:Void->Void = null) {
		for (popup in _popups)
		{
			if(popup == null) continue;
			popup.intendedY += 150;
		}

		var newPop:AchievementPopup = new AchievementPopup(achieve, endFunc);
		_popups.push(newPop);
		//trace('Giving achievement ' + achieve);
	}

	// Map sorting cuz haxe is physically incapable of doing that by itself
	static var _sortID = 0;
	static var _originalLength = -1;
	public static function createAchievement(name:String, data:Achievement, ?mod:String = null)
	{
		data.ID = _sortID;
		data.mod = mod;
		achievements.set(name, data);
		_sortID++;
	}

	#if MODS_ALLOWED
	public static function reloadList()
	{
		// remove modded achievements
		if((_sortID + 1) > _originalLength)
			for (key => value in achievements)
				if(value.mod != null)
					achievements.remove(key);

		_sortID = _originalLength-1;

		var modLoaded:String = Mods.currentModDirectory;
		Mods.currentModDirectory = null;
		loadAchievementJson(Paths.mods('data/achievements.json'));
		for (i => mod in Mods.parseList().enabled)
		{
			Mods.currentModDirectory = mod;
			loadAchievementJson(Paths.mods('$mod/data/achievements.json'));
		}
		Mods.currentModDirectory = modLoaded;
	}

	inline static function loadAchievementJson(path:String, addMods:Bool = true)
	{
		var retVal:Array<Dynamic> = null;
		if(FileSystem.exists(path)) {
			try {
				var rawJson:String = File.getContent(path).trim();
				if(rawJson != null && rawJson.length > 0) retVal = tjson.TJSON.parse(rawJson); //Json.parse('{"achievements": $rawJson}').achievements;
				
				if(addMods && retVal != null)
				{
					for (i in 0...retVal.length)
					{
						var achieve:Dynamic = retVal[i];
						if(achieve == null)
						{
							var errorTitle = 'Mod name: ' + Mods.currentModDirectory != null ? Mods.currentModDirectory : "None";
							var errorMsg = 'Achievement #${i+1} is invalid.';
							#if windows
							lime.app.Application.current.window.alert(errorMsg, errorTitle);
							#end
							trace('$errorTitle - $errorMsg');
							continue;
						}

						var key:String = achieve.save;
						if(key == null || key.trim().length < 1)
						{
							var errorTitle = 'Error on Achievement: ' + (achieve.name != null ? achieve.name : achieve.save);
							var errorMsg = 'Missing valid "save" value.';
							#if windows
							lime.app.Application.current.window.alert(errorMsg, errorTitle);
							#end
							trace('$errorTitle - $errorMsg');
							continue;
						}
						key = key.trim();
						if(achievements.exists(key)) continue;

						createAchievement(key, achieve, Mods.currentModDirectory);
					}
				}
			} catch(e:Dynamic) {
				var errorTitle = 'Mod name: ' + Mods.currentModDirectory != null ? Mods.currentModDirectory : "None";
				var errorMsg = 'Error loading achievements.json: $e';
				#if windows
				lime.app.Application.current.window.alert(errorMsg, errorTitle);
				#end
				trace('$errorTitle - $errorMsg');
			}
		}
		return retVal;
	}
	#end

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State)
	{
		Lua_helper.add_callback(lua, "getAchievementScore", function(name:String):Float
		{
			if(!achievements.exists(name))
			{
				FunkinLua.luaTrace('getAchievementScore: Couldnt find achievement: $name', false, false, FlxColor.RED);
				return -1;
			}
			return getScore(name);
		});
		Lua_helper.add_callback(lua, "setAchievementScore", function(name:String, ?value:Float = 0, ?saveIfNotUnlocked:Bool = true):Float
		{
			if(!achievements.exists(name))
			{
				FunkinLua.luaTrace('setAchievementScore: Couldnt find achievement: $name', false, false, FlxColor.RED);
				return -1;
			}
			return setScore(name, value, saveIfNotUnlocked);
		});
		Lua_helper.add_callback(lua, "addAchievementScore", function(name:String, ?value:Float = 1, ?saveIfNotUnlocked:Bool = true):Float
		{
			if(!achievements.exists(name))
			{
				FunkinLua.luaTrace('addAchievementScore: Couldnt find achievement: $name', false, false, FlxColor.RED);
				return -1;
			}
			return addScore(name, value, saveIfNotUnlocked);
		});
		Lua_helper.add_callback(lua, "unlockAchievement", function(name:String):Dynamic
		{
			if(!achievements.exists(name))
			{
				FunkinLua.luaTrace('unlockAchievement: Couldnt find achievement: $name', false, false, FlxColor.RED);
				return null;
			}
			return unlock(name);
		});
		Lua_helper.add_callback(lua, "isAchievementUnlocked", function(name:String):Dynamic
		{
			if(!achievements.exists(name))
			{
				FunkinLua.luaTrace('isAchievementUnlocked: Couldnt find achievement: $name', false, false, FlxColor.RED);
				return null;
			}
			return isUnlocked(name);
		});
		Lua_helper.add_callback(lua, "achievementExists", function(name:String) return achievements.exists(name));
	}
	#end
}
#end