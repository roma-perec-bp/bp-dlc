package cutscenes;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import backend.StageData;
import objects.VideoSprite;


class CutsceneState extends MusicBeatState
{
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
			var cutscene:VideoSprite = new VideoSprite(fileName, false, true, false, false);

			function onVideoEnd()
			{
				cutscene = null;
				LoadingState.loadAndSwitchState(new PlayState());
				Init.fun = -1;
			}

			cutscene.finishCallback = onVideoEnd;
			cutscene.onSkip = onVideoEnd;

            add(cutscene);

            cutscene.videoSprite.play();
		}
		#else
		FlxG.log.warn('Platform not supported!');
		LoadingState.loadAndSwitchState(new PlayState());
		Init.fun = -1;
		#end
    }
}