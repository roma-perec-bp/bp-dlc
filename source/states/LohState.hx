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
			videoCutscene = new VideoSprite(fileName, false, true, false);

			function onVideoEnd()
			{
				videoCutscene = null;
				MusicBeatState.switchState(new PlayState());
			}

			videoCutscene.finishCallback = onVideoEnd;
			videoCutscene.onSkip = onVideoEnd;

            add(videoCutscene);

            videoCutscene.play();
		}
		#else
		FlxG.log.warn('Platform not supported!');
		MusicBeatState.switchState(new PlayState());
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