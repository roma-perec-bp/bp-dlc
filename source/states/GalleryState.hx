package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;
import backend.StageData;
import backend.Song;
import states.FreeplayState;

import flixel.addons.display.FlxBackdrop;

class GalleryState extends MusicBeatState
{
    var images = [];
    var paths = ["Arts", "Ost Arts", "Comics", "Memes", "Other", "Devil Content"];
    var name:FlxText; 
    var author:FlxText;
    var pathname:FlxText;

    var leftArrows:FlxSprite;
	var rightArrows:FlxSprite;

    var debug:FlxText;

    var mouseWheel:Float = 0;

    var curSelected:Int = 0;

    var ex_box:FlxSprite;

    var canDo:Bool = true;

    public var sprItemsGroup:FlxTypedGroup<FlxSprite>;

	override function create()
    {
        final ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

        var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("gallery_pvz/bg"));
        add(bg);

        if(FlxG.save.data.ending == false)
            paths = ["Arts", "Ost Arts", "Comics", "Memes", "Other"];

        for(j in 0...paths.length)
        {
            for (i in FileSystem.readDirectory(FileSystem.absolutePath('assets/shared/images/gallery_pvz/${
                paths[j].toLowerCase()
            }')))
            {
                var text:String = i.substring(0, i.indexOf('.png'));
                images.push(text);
            }
        }

        FlxG.mouse.visible = true;

		sprItemsGroup = new FlxTypedGroup<FlxSprite>();
		add(sprItemsGroup);

        var curID:Int = -1;
        
        for(j in 0...paths.length)
        {
            for(k in 0...images.length)
            {
                var image:String = images[k];
                var delimiterIndex:Int = image.indexOf("$");
                if (FileSystem.exists(Paths.getPath('images/gallery_pvz/${paths[j].toLowerCase()}/' +image+'.png')))
                {
                    curID += 1;
                    var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gallery_pvz/${paths[j].toLowerCase()}/' + 
                        image
                    ));
                    spr.scale.set(0.5, 0.5);
                    spr.updateHitbox();
                    spr.screenCenter();
                    spr.alpha = 0;
                    spr.ID = curID;
                    sprItemsGroup.add(spr);
                }

            }
        };

        ex_box = new FlxSprite(0, 0);
        ex_box.antialiasing = ClientPrefs.data.antialiasing;
        ex_box.frames = Paths.getSparrowAtlas('gallery_ex');
        ex_box.animation.addByPrefix('idle', "attack", 24, false);
        ex_box.animation.play('idle');
        add(ex_box);
        ex_box.alpha = 0.0001;

        name = new FlxText(0, 25, 0, "", 55);
		name.text = "Hello";
		name.setFormat(Paths.font("HouseofTerror.ttf"), 45, 0xFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		name.borderSize = 3;
		name.screenCenter(X);
		add(name);
        
        author = new FlxText(0, 65, 0, "", 35);
		author.text = "Hello";
		author.setFormat(Paths.font("HouseofTerror.ttf"), 30, 0xFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		author.borderSize = 3;
		author.screenCenter(X);
		add(author);
        
        pathname = new FlxText(0, FlxG.height - 85, 0, "", 35);
		pathname.text = "Hello";
		pathname.setFormat(Paths.font("HouseofTerror.ttf"), 45, 0xFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		pathname.borderSize = 3;
		pathname.screenCenter(X);
		add(pathname);

        debug = new FlxText(5, 5, 0, "You can use the mouse wheel to zoom in and out of the picture!", 55);
		debug.setFormat(Paths.font("HouseofTerror.ttf"), 15, 0xFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        debug.alpha = 0.7;
        debug.screenCenter(X);
		debug.borderSize = 1.5;
		add(debug);

        if (leftArrows == null){
			leftArrows = new FlxSprite(10, 300);
			leftArrows.antialiasing = ClientPrefs.data.antialiasing;
			leftArrows.frames = ui_tex;
			leftArrows.animation.addByPrefix('idle', "arrow left");
			leftArrows.animation.addByPrefix('press', "arrow push left");
			leftArrows.animation.play('idle');
		}
		add(leftArrows);

		if (rightArrows == null){
			rightArrows = new FlxSprite(leftArrows.x + 1210, leftArrows.y);
			rightArrows.antialiasing = ClientPrefs.data.antialiasing;
			rightArrows.frames = ui_tex;
			rightArrows.animation.addByPrefix('idle', 'arrow right');
			rightArrows.animation.addByPrefix('press', "arrow push right", 24, false);
			rightArrows.animation.play('idle');
		}
		add(rightArrows);
        
        changeButtons();
        name.screenCenter(X);
        author.screenCenter(X);
        pathname.screenCenter(X);

        
		FlxG.sound.playMusic(Paths.music('gallerymenu'), 1, true);

        #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("GALLERY", null);
		#end

        super.create();
    }

    override function update(elapsed:Float) 
    {
        if (canDo)
        {
            if (controls.UI_RIGHT || FlxG.mouse.overlaps(rightArrows))
                rightArrows.animation.play('press')
            else
                rightArrows.animation.play('idle');
    
            if (controls.UI_LEFT || FlxG.mouse.overlaps(leftArrows))
                leftArrows.animation.play('press');
            else
                leftArrows.animation.play('idle');
    
            if (controls.UI_LEFT_P || FlxG.mouse.overlaps(leftArrows) && FlxG.mouse.justPressed)
            {
                changeButtons(-1);
                name.screenCenter(X);
                author.screenCenter(X);
                pathname.screenCenter(X);
                FlxG.sound.play(Paths.sound('scrollMenu'));
            }
            
            if (controls.UI_RIGHT_P || FlxG.mouse.overlaps(rightArrows) && FlxG.mouse.justPressed) 
            {
                changeButtons(1);
                name.screenCenter(X);
                author.screenCenter(X);
                pathname.screenCenter(X);
                FlxG.sound.play(Paths.sound('scrollMenu'));
            }
        }

        if (FlxG.save.data.beatUnfuck && !FlxG.save.data.unlockedSong.contains('exerection'))
            ex_box.offset.set(FlxG.random.float(-16, 16), FlxG.random.float(-16, 16));

        if (FlxG.save.data.beatUnfuck && canDo && !FlxG.save.data.unlockedSong.contains('exerection'))
        {
            if(controls.ACCEPT && (curSelected == 15 || curSelected == 16)) {
                canDo = false;

                ex_box.scale.set(1 + mouseWheel, 1 + mouseWheel);

                FlxTween.tween(ex_box.scale, {x: 0.65 + mouseWheel, y: 0.65 + mouseWheel}, 0.5, {
                    ease: FlxEase.bounceOut,
                });

                ex_box.updateHitbox();
                ex_box.screenCenter();
               //ex_box.x += 255;
                FlxG.camera.shake(0.066, 0.2);
                FlxTween.tween(FlxG.camera, {zoom:1.4}, 5, {ease: FlxEase.expoOut, type: BACKWARD});
                sprItemsGroup.forEach(function(spr:FlxSprite)
                {
                    spr.color = 0xFF000000;
                    spr.alpha = 0;
                });
                ex_box.alpha = 1;
                ex_box.animation.play('idle');
                FlxG.sound.play(Paths.sound('exerection_unlock'));
                FlxG.camera.flash(0xFFFF0000, 0.6, null, true);

                new FlxTimer().start(2, function(tmr:FlxTimer)
                {
                    FlxG.camera.fade(0xFF000000, 2);
                });

                new FlxTimer().start(7, function(tmr:FlxTimer)
                {
                    PlayState.storyPlaylist = ['exerection'];
                    PlayState.isStoryMode = true;
    
                    FreeplayState.curSelected = 1;
            
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
                    return;
                });
            }
        }

        sprItemsGroup.forEach(function(spr:FlxSprite)
        {
            var centX = (FlxG.width/2) - (spr.width /2);
            var centY = (FlxG.height/2) - (spr.height /2);
            spr.x = FlxMath.lerp(spr.x, centX - (curSelected-spr.ID) * 800, FlxMath.bound(elapsed * 10, 0, 1));
            spr.scale.set(
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 0.75 + mouseWheel, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.3, FlxMath.bound(elapsed * 10.2, 0, 1)),
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.scale.x, 0.75 + mouseWheel, FlxMath.bound(elapsed * 10.2, 0, 1))
                    :
                    FlxMath.lerp(spr.scale.x, 0.3, FlxMath.bound(elapsed * 10.2, 0, 1))
            );

            if(canDo)
            {
                spr.alpha = (
                    spr.ID == curSelected ?
                        FlxMath.lerp(spr.alpha, 1, FlxMath.bound(elapsed * 5, 0, 1))
                        :
                        FlxMath.lerp(spr.alpha, 0.25, FlxMath.bound(elapsed * 5, 0, 1))
                );
            }
        });

        if(canDo) mouseWheel += (FlxG.mouse.wheel / 10);

        if(controls.BACK && canDo)
        {
            canDo = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7, true);
            MusicBeatState.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }

    function changeButtons(index:Int = 0)
    {
        curSelected += index;

        if (curSelected >= images.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = images.length - 1;

        restartText(images[curSelected]);

        mouseWheel -= mouseWheel;

        if(FlxG.save.data.beatUnfuck && (curSelected == 15 || curSelected == 16) && !FlxG.save.data.unlockedSong.contains('exerection'))
        {
            debug.text = "Press ENTER...";
            FlxG.sound.music.volume = 0;
            debug.screenCenter(X);
        }
        else
        {
            debug.text = "You can use the mouse wheel to zoom in and out of the picture!";
            FlxG.sound.music.volume = 1;
            debug.screenCenter(X);
        }
    }

    function restartText(image:String)
    {
        var delimiterIndex:Int = image.indexOf("$");
        var delimiterIndex2:Int = image.indexOf(".png");

        var picturename:String = image.substring(0, delimiterIndex);
        var authorname:String = image.substring(delimiterIndex + 1);

        name.text = picturename;
        author.text = "By: " + authorname;

        for(j in 0...paths.length)
        {
            if (FileSystem.exists(Paths.getPath('images/gallery_pvz/${paths[j].toLowerCase()}/'+image+'.png')))
            {
                pathname.text = paths[j];
            }
        }

        if(pathname.text == 'Comics')
        {
            name.visible = false;
            author.visible = false;
        }
        else
        {
            name.visible = true;
            author.visible = true;
        }
    }
}