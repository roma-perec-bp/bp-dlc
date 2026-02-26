package states;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import backend.Song;

import backend.StageData;
import objects.VideoSprite;


class CompleteState extends MusicBeatState
{
    public var videoCutscene:VideoSprite = null;
    override function create()
	{
		Achievements.unlock('secretsongs');
		FlxG.camera.bgColor = 0xFF000000; //пизда

		var foundFile:Bool = false;
		var fileName:String = Paths.video('complete');

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("All secret songs are done", null);
		#end

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
				PlayState.storyPlaylist = ['holy-hell'];
          		PlayState.isStoryMode = true;
    
           		Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '', PlayState.storyPlaylist[0].toLowerCase());

            	var directory = StageData.forceNextDirectory;
				LoadingState.loadNextDirectory();
				StageData.forceNextDirectory = directory;

            	@:privateAccess
				if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
				{
					trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
					Paths.freeGraphicsFromMemory();
				}

				LoadingState.prepareToSong();
				LoadingState.loadAndSwitchState(new PlayState());
    
            	FlxG.sound.music.stop();
			}

			videoCutscene.finishCallback = onVideoEnd;
			videoCutscene.onSkip = onVideoEnd;

            add(videoCutscene);

            videoCutscene.play();
		}
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