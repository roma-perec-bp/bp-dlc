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
				LoadingState.loadAndSwitchState(new PlayState());
				Init.fun = -1;
			}

			videoCutscene.finishCallback = onVideoEnd;
			videoCutscene.onSkip = onVideoEnd;

            add(videoCutscene);

            videoCutscene.play();
		}
		#else
		FlxG.log.warn('Platform not supported!');
		LoadingState.loadAndSwitchState(new PlayState());
		Init.fun = -1;
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