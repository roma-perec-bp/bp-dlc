package cutscenes;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import backend.StageData;
import objects.VideoSprite;


class CutsceneState extends MusicBeatState
{
	public var videoCutscene:VideoSprite = null;

    override function create()
	{
		FlxG.camera.bgColor = 0xFF000000; //пизда

		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = Paths.video('ads/2');

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile)
		{
			videoCutscene = new VideoSprite(fileName, false, true, false);

			function onVideoEnd()
			{
				videoCutscene = null;
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

			videoCutscene.finishCallback = onVideoEnd;
			videoCutscene.onSkip = onVideoEnd;

            add(videoCutscene);

            videoCutscene.play();
		}
		#else
		FlxG.log.warn('Platform not supported!');
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
		#end
    }

	override function destroy() 
	{
		#if VIDEOS_ALLOWED
		if(videoCutscene != null)
		{
			videoCutscene.destroy();
			videoCutscene = null;
		}
		#end

		super.destroy();
	}
}