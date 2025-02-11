
--How makeLuaSprite works:
--makeLuaSprite(<SPRITE VARIABLE>, <SPRITE IMAGE FILE NAME>, <X>, <Y>);
--"Sprite Variable" is how you refer to the sprite you just spawned in other methods like "setScrollFactor" and "scaleObject" for example

--so for example, i made the sprites "stagelight_left" and "stagelight_right", i can use "scaleObject('stagelight_left', 1.1, 1.1)"
--to adjust the scale of specifically the one stage light on left instead of both of them

function onCreate()
	-- background shit
	makeLuaSprite('sky', 'EXE1/Castillo fondo de hasta atras', -700, -825);
	setScrollFactor('sky', 0.75, 0.75);
	
  if not lowQuality then
    makeAnimatedLuaSprite('fire1', 'EXE1/starman/Starman_BG_Fire_Assets', -700, 600);
    addAnimationByPrefix('fire1', 'dance', 'fire anim effects', 24, true);
    playAnim ('fire1', 'dance', false);
    setProperty('fire1.alpha', 0);
   
    makeAnimatedLuaSprite('fire2', 'EXE1/starman/Starman_BG_Fire_Assets', 700, 600);
    addAnimationByPrefix('fire2', 'dance', 'fire anim effects', 24, true);
    playAnim ('fire2', 'dance', false);
    setProperty('fire2.alpha', 0);
  end
	
	makeLuaSprite('floor', 'EXE1/Suelo y brillo atmosferico', -675, -825);
	
	 makeLuaSprite('things', 'EXE1/Arboles y sombra', -625, -825);
	
	 makeLuaSprite('box above', 'EXE1/CLadrillosPapus', -605, -745);

	makeLuaSprite('black', 'EXE1/black', 0, 0);
	scaleObject('black', 10, 10)
	setObjectOrder('black', 3)
	setProperty('black.alpha', 0)

	addLuaSprite('sky', false);

  if not lowQuality then
	addLuaSprite('fire1', false);
	addLuaSprite('fire2', false);
  end
	addLuaSprite('floor', false);
	addLuaSprite('box above', false);
	addLuaSprite('things', false);
end

function onCreatePost()
  makeLuaSprite('dark', 'EXE1/dark', 0, 0);
  scaleObject('dark', 1, 1);
 setObjectCamera('dark', 'camOther');
  setProperty('dark.alpha', 0.85)
 
  makeLuaSprite('smoke', 'EXE1/smoke', 0, 0);
  scaleObject('smoke', 1, 1);
 setObjectCamera('smoke', 'camOther');
  setProperty('smoke.alpha', 0) 
  doTweenAlpha('smoketween', 'smoke', 0, 0, 'linear');

  addLuaSprite('dark', true);
	addLuaSprite('smoke', true);
  --addLuaSprite('black', true);
end

function onStepHit() -- The assets tween thingy
           if curStep == 2080 then
            if not lowQuality then
              doTweenY('fire1TweenY', 'fire1', -200, 13, 'linear')
    
              doTweenY('fire2TweenY', 'fire2', -200, 13, 'linear')
              
              setProperty('fire1.alpha', 1);
              
              setProperty('fire2.alpha', 1);
            end
end

      if curStep == 2100 then
    
    doTweenAlpha('smoketween2', 'smoke', 0.75, 13, 'linear');
    
    doTweenAlpha('darktween2', 'dark', 1, 13, 'linear');
    end
    
    if curStep == 2336 then
    
    doTweenAlpha('blacktween1', 'black', 1, 3.5, 'linear');
    
    doTweenAlpha('smoketween2', 'smoke', 0, 3.5, 'linear');
    
    doTweenAlpha('darktween2', 'dark', 0, 3.5, 'linear');
    
    end

function onBeatHit() -- Camera Zoom thingy
   if curBeat == 204 then
     setProperty('defaultCamZoom', 0.675);
   end
   
   if curBeat == 236 then
   setProperty('defaultCamZoom', 0.55);
   end
   
   if curBeat == 268 then
   setProperty('defaultCamZoom', 0.425);
   end
   
   if curBeat == 272 then
   setProperty('defaultCamZoom', 0.55);
   end
   
   if curBeat == 304 then
   setProperty('defaultCamZoom', 0.485);
   end
   
   if curBeat == 340 then
   setProperty('defaultCamZoom', 0.55);
   end
   
   if curBeat == 344 then
   setProperty('defaultCamZoom', 0.435);
   end
   
   if curBeat == 356 then
   setProperty('defaultCamZoom', 0.485);
   end
   
   if curBeat == 388 then
   setProperty('defaultCamZoom', 0.55);
   end
   
   if curBeat == 452 then
   setProperty('defaultCamZoom', 0.485);
   end
   
   if curBeat == 484 then
   setProperty('defaultCamZoom', 0.575);
   end
   
   if curBeat == 488 then
   setProperty('defaultCamZoom', 0.625);
   end
   
   if curBeat == 492 then
   setProperty('defaultCamZoom', 0.675);
   end
   
   if curBeat == 496 then
   setProperty('defaultCamZoom', 0.7);
   end
   
   if curBeat == 500 then
   setProperty('defaultCamZoom', 0.55);
   end
   
   if curBeat == 504 then
   setProperty('defaultCamZoom', 0.5);
   end
   
   if curBeat == 508 then
   setProperty('defaultCamZoom', 0.45);
   end
   
   if curBeat == 512 then
   setProperty('defaultCamZoom', 0.44);
   end
   
   if curBeat == 516 then
   setProperty('defaultCamZoom', 0.55);
   end
   
   if curBeat == 520 then
   setProperty('defaultCamZoom', 0.485);
   end
   
   if curBeat == 552 then
   setProperty('defaultCamZoom', 0.7);
   end
 end
end