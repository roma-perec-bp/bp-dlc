function onCreate()
    makeLuaSprite('black', nil)
    makeGraphic('black', 1280, 720, '000000')
    setObjectCamera("black", 'other')
    addLuaSprite('black')

    makeLuaSprite('qwerty', 'cyberPedo')
    setObjectCamera("qwerty", 'other')
    setProperty('qwerty.visible', false)
    addLuaSprite('qwerty', true)

   setProperty('camHUD.alpha', 0)
end

function onBeatHit()
    if curBeat == 4 then
        doTweenAlpha('qwqw', 'black', 0, 4.5)
    end

    if curBeat == 38 then
        setProperty('qwerty.visible', true)
        doTweenAlpha('qwqw', 'qwerty', 0, 1)
        cameraShake("other", 0.04, 0.1)
    end

    if curBeat == 40 then
        doTweenAlpha('huh', 'camHUD', 1, 0.5)
    end

    if curBeat == 44 then
        removeLuaSprite('qwerty', true)
    end
end

function onEvent(name, value1, value2)
	if name == 'Fade UI Complete' then
        doTweenAlpha('qwqw', 'black', 1, 6, "quartInOut")
	end
end