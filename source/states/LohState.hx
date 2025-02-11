package states;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import backend.StageData;
import objects.VideoSprite;


class LohState extends MusicBeatState
{
	var videoShow:Int = 0;
    public var videoCutscene:VideoSprite = null;
    override function create()
	{
		FlxG.camera.bgColor = 0xFF000000; //пизда
        videoShow = FlxG.random.int(0, 14); //гыгыгы

		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = Paths.video('chart/'+videoShow);

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
				MusicBeatState.switchState(new PlayState());
			}

			cutscene.finishCallback = onVideoEnd;
			cutscene.onSkip = onVideoEnd;

            add(cutscene);

            cutscene.play();
		}
		#else
		FlxG.log.warn('Platform not supported!');
		MusicBeatState.switchState(new PlayState());
		#end
    }
}