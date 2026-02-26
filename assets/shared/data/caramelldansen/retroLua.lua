local pos = 625            --    notes pos
local camScale = 1.6    --    camera Scale

function onCreate()
    setProperty('camHUD.flashSprite.scaleX', camScale)
    setProperty('camHUD.flashSprite.scaleY', camScale)
end

function onCreatePost()
    --    hud pos
    if not downscroll then
        pos = -10
        setProperty('healthBar.y', 750)
        setProperty('scoreTxt.y', 660)
        setProperty('scoreTxt.x', 60)
        setProperty('timeBar.y', -60)
        setProperty('timeTxt.y', -65)
        setProperty('accuracyShit.y', 770)
        setProperty('medal.y', 560)
    else
        setProperty('healthBar.y', -25)
        setProperty('scoreTxt.y', 660)
        setProperty('scoreTxt.x', 60)
        setProperty('timeBar.y', 750)
        setProperty('timeTxt.y', 740)
        setProperty('accuracyShit.y', -85)
        setProperty('medal.y', 560)
    end
    
    --    black borders
    makeLuaSprite('borde1', nil, 0, 0)
    makeGraphic('borde1', 150, screenHeight, '000000')
    setObjectCamera('borde1', 'camOther')
    addLuaSprite('borde1', false)
    
    makeLuaSprite('borde2', nil, screenWidth - 150, 0)
    makeGraphic('borde2', 150, screenHeight, '000000')
    setObjectCamera('borde2', 'camOther')
    addLuaSprite('borde2', false)
    
    for i = 0, 7 do 
        noteTweenY('note'..i, i, pos, 0.001, 'linear')
    end 
end

function onUpdatePost()
    runHaxeCode("game.camHUD.setScale(game.camHUD.zoom / 2, game.camHUD.zoom / 2);")
end