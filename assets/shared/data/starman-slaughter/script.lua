function onCreate()
    makeLuaSprite('black', nil)
    makeGraphic('black', 1280, 720, '000000')
    setObjectCamera("black", 'other')
    addLuaSprite('black')

    makeLuaSprite('qwerty', 'roofShit')
    setObjectCamera("qwerty", 'other')
    setProperty('qwerty.visible', false)
    screenCenter('qwerty', 'xy')
    addLuaSprite('qwerty', true)

   setProperty('camHUD.alpha', 0)
end

function onCreatePost()
    setObjectOrder('gfGroup', 7)
end

function onSongStart()
    setProperty('black.alpha', 0)
    setProperty('camHUD.alpha', 1)
    cameraFlash('camHUD', 'FF0000', 1, true)
end

function onBeatHit()
    if curBeat == 34 then
        setProperty('qwerty.visible', true)
        cameraShake("other", 0.05, 0.87)
    end

    if curBeat == 36 then
        cameraFlash('camHUD', 'FF0000', 1, true)
        removeLuaSprite('qwerty', true)
    end
end