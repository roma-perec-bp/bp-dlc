local defaultScaleX
local defaultScaleY

local y = 0
local x = 0

local noAngle = false

local defaultNotePos = {};

local turn = 10
local turn2 = 20

local Meow1 = 0
local Meow2 = 112
local Meow3 = 112 * 2
local Meow4 = 112 * 3

local balls = false
local dance = false
local shit = true
local shitScroll
local scaleShit

local downscrollMoment = false

local initScroll

local l = false

local sinY = 70

local strumMovimentForce = 0

wigglefreq = 80
wiggleamp = 20

function onCreate()
    math.randomseed(os.clock() * 4500); --майкл зомбекшон

    makeLuaText("playerWait", "WAITING FOR\nPLAYER 1", 600, 25, 200);
    setTextSize('playerWait', 48)
    setTextFont("playerWait", 'mariones.ttf')
    setObjectCamera("playerWait", "camHUD");
    addLuaText("playerWait");
    setProperty('playerWait.visible', false)

    if middlescroll then
        screenCenter('playerWait', 'xy')
    end

    initScroll = downscroll
    downscrollMoment = downscroll
end

function onCreatePost()
    if downscroll then
        sinY = 550;
    end
end

function onDestroy()
    setPropertyFromClass('backend.ClientPrefs', 'data.downScroll', initScroll);
end

function onSongStart()
    if respawnPoint == 0 then --start
        for i = 0, 3 do
            setPropertyFromGroup('strumLineNotes', i, 'visible', false)
        end

        runHaxeCode([[
            game.songLength = (141 * 1000);
        ]]);
    end

    if respawnPoint == 1 then --wave 2
        runHaxeCode([[
            game.songLength = (306 * 1000);
        ]]);
    end 

    if respawnPoint == 2 then --wave 3
        runHaxeCode([[
            game.songLength = (484 * 1000);
        ]]);
    end 

    if respawnPoint == 3 then --wave 4
        for i = 0, 3 do
            noteTweenAlpha("note"..i, i, 0, 1, "quadInOut")
        end

        runHaxeCode([[
            game.songLength = (9999 * 1000);
        ]]);
    end
    
	for i = 0,7 do 
		x = getPropertyFromGroup('strumLineNotes', i, 'x')

		y = getPropertyFromGroup('strumLineNotes', i, 'y')

        defaultScaleX = getPropertyFromGroup('strumLineNotes', i, 'scale.x')
        defaultScaleY = getPropertyFromGroup('strumLineNotes', i, 'scale.y')

		table.insert(defaultNotePos, {x,y})
	end
end

function onSpawnNote(membersIndex, noteData, noteType, isSustainNote)
    if shitScroll then
        if isSustainNote then
            flipY = getPropertyFromGroup('notes', membersIndex, 'flipY')
            if flipY == true then
                setPropertyFromGroup('notes', membersIndex, 'flipY', false)
            else
                setPropertyFromGroup('notes', membersIndex, 'flipY', true)
            end
        end
    end
end

local staticArrowWave = 0
local upShit = 0
local staticArrowWave = 0
local function lerp(a,b,t) return a+(b-a)*t end
function onUpdate(elapsed)
	local songPos = getPropertyFromClass('backend.Conductor', 'songPosition');
  	local songPosSpeed = getPropertyFromClass('backend.Conductor', 'songPosition') / 500
    songPosFinal = getSongPosition()
	currentBeat = (songPos / 1750) * (bpm / 100)
	currentBeatAlt = (songPos / 1250) * (bpm / 100)

  	if curBeat >= 128 and curBeat <= 143 then --МЫ МЫ БРУТАЛ ЭКС ПАРТ
		for i = 0,7 do
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 10 *math.sin((currentBeat + i*0.25) * math.pi))
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
		end
	end

    if curBeat >= 208 and curBeat < 215 or curBeat >= 224 and curBeat < 231 or curBeat >= 240 and curBeat < 247 or curBeat >= 256 and curBeat < 263 then --ТЫ НЕ ЕБЕЩБ НАС БРУТАЛ ЕБЕЩБ НАС
		for i = 0,7 do
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 25 *math.sin((currentBeatAlt + i*0.25) * math.pi))
		end
	end

    if curBeat >= 380 and curBeat < 384 or curBeat >= 388 and curBeat <= 391 then --ПАРТ 1 ХАРД СТАЙЛ АХ ЭХ У И АААХ
        for i = 0,3 do
            local noteX = 120 * i
            local offsetX = 320
            local thingy = 1
            if curBeat % 2 == 0 then
              thingy = -1
            end
            setPropertyFromGroup("strumLineNotes", i + 4, "y", defaultPlayerStrumY0+(math.sin((getSongPosition()-getPropertyFromClass('backend.ClientPrefs','data.noteOffset')) / crochet + (noteX-120)*2) * staticArrowWave + staticArrowWave * 0.5))
      
            setPropertyFromGroup("strumLineNotes", i + 4, "x", getPropertyFromGroup('strumLineNotes', 0, 'x')+noteX+offsetX+(thingy*staticArrowWave)*0.7)
          end
          staticArrowWave = lerp(staticArrowWave,0,elapsed*8)
    end

    if curBeat >= 476 and curBeat <= 506 then --начало движениями
		for i = 0,3 do
			setPropertyFromGroup('strumLineNotes', i, 'x',  _G['defaultOpponentStrumX'..i] + 10 *math.sin((currentBeat + i*0.25) * math.pi))
            setPropertyFromGroup('strumLineNotes', i+4, 'x',  _G['defaultPlayerStrumX'..i] + 10 *math.sin((currentBeat + i*0.25) * math.pi))

			setPropertyFromGroup('strumLineNotes', i, 'y', _G['defaultOpponentStrumY'..i] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
            setPropertyFromGroup('strumLineNotes', i+4, 'y',  _G['defaultPlayerStrumY'..i] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
		end
	end

    if curBeat >= 541 and curBeat <= 571 then --старт парта где будет видео
		for i = 0,7 do
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos2[i + 1][1] + 25 *math.sin((currentBeat + i*0.25) * math.pi))
		end
	end

    if curBeat >= 608 and curBeat <= 675 then --после того парта туда сюда ноты
        if not middlescroll then
            for i =0,7 do
                local noteXwave = 120 * i
                local offsetXwave = 140
                if i<4 then
                  offsetXwave = 0
                end
          
                setPropertyFromGroup("strumLineNotes", i, "x", defaultOpponentStrumX0+noteXwave+offsetXwave+(wiggleThing)*0.7)
            end
        
            wiggleThing = lerp(wiggleThing,0,elapsed*8)
        end
    end

    if curBeat >= 645 and curBeat <= 675 then --пока идет парт ноты летают
        for i =0,3 do
            setPropertyFromGroup('strumLineNotes', i, 'y',  _G['defaultOpponentStrumY'..i] + 10 *math.cos((currentBeatAlt + i*0.25) * math.pi))
            setPropertyFromGroup('strumLineNotes', i + 4, 'y',  _G['defaultPlayerStrumY'..i] + 10 *math.cos((currentBeatAlt + i*0.25) * math.pi))
        end
    end

    if curBeat >= 677 and curBeat <= 691 then --перец манипулирует и ноты вообще да
        for i = 0,3 do
			setPropertyFromGroup('strumLineNotes', i, 'x',  _G['defaultOpponentStrumX'..i] + 10 *math.sin((currentBeatAlt + i*0.25) * math.pi))
            setPropertyFromGroup('strumLineNotes', i+4, 'x',  _G['defaultPlayerStrumX'..i] + 10 *math.sin((currentBeatAlt + i*0.25) * math.pi))

			setPropertyFromGroup('strumLineNotes', i, 'y', _G['defaultOpponentStrumY'..i] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
            setPropertyFromGroup('strumLineNotes', i+4, 'y',  _G['defaultPlayerStrumY'..i] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
		end
    end

    if curBeat >= 692 and curBeat <= 706 then --все еще зомби под гипнозом но ситуации пиздец
        for i =0,7 do
          local noteXup = 120 * i
          local thingy = 1
          if curBeat % 2 == 0 then
            thingy = -1
          end
          setPropertyFromGroup("strumLineNotes", i, "y", defaultOpponentStrumY0+(math.sin((getSongPosition()-getPropertyFromClass('backend.ClientPrefs','data.noteOffset')) / crochet + (noteXup-120)*2) * upShit + upShit * 0.5))
        end
        upShit = lerp(upShit,0,elapsed*8)

        for i = 0,3 do
            setPropertyFromGroup('strumLineNotes', i, 'x',  _G['defaultOpponentStrumX'..i] + 10 *math.sin((currentBeatAlt + i*0.25) * math.pi))
            setPropertyFromGroup('strumLineNotes', i+4, 'x',  _G['defaultPlayerStrumX'..i] + 10 *math.sin((currentBeatAlt + i*0.25) * math.pi))
        end
    end

    if curBeat >= 776 and curBeat <= 807 then --ХАРД СТАЙЛ
        for i = 0,3 do
            local noteX = 120 * i
            local offsetX = 320
            local thingy = 1
            if curBeat % 2 == 0 then
              thingy = -1
            end
            setPropertyFromGroup("strumLineNotes", i + 4, "y", defaultPlayerStrumY0+(math.sin((getSongPosition()-getPropertyFromClass('backend.ClientPrefs','data.noteOffset')) / crochet + (noteX-120)*2) * staticArrowWave + staticArrowWave * 0.5))
      
            setPropertyFromGroup("strumLineNotes", i + 4, "x", getPropertyFromGroup('strumLineNotes', 0, 'x')+noteX+offsetX+(thingy*staticArrowWave)*0.7)
          end
          staticArrowWave = lerp(staticArrowWave,0,elapsed*8)
    end

    if curBeat >= 872 and curBeat <= 918 then --пока идет парт ноты летают
        for i =0,3 do
            setPropertyFromGroup('strumLineNotes', i, 'y',  _G['defaultOpponentStrumY'..i] + 50 *math.cos((currentBeatAlt *1) * math.pi))
            setPropertyFromGroup('strumLineNotes', i + 4, 'y',  _G['defaultPlayerStrumY'..i] + 50 *math.cos((currentBeatAlt *1) * math.pi))
        end
    end

    if curBeat >= 952 and curBeat < 982 then --во время парта с еще одним видео ноты идут бум шагают
        for i=0,3 do
            setPropertyFromGroup('opponentStrums', i, 'x', getPropertyFromGroup('opponentStrums', i, 'x') + 16 * (elapsed/(1/60)))
            if getPropertyFromGroup('opponentStrums', i, 'x') > screenWidth then
                setPropertyFromGroup('opponentStrums', i, 'x', 0 - getPropertyFromGroup('opponentStrums', i, 'width'))
            end
            setPropertyFromGroup('playerStrums', i, 'x', getPropertyFromGroup('playerStrums', i, 'x') + 16 * (elapsed/(1/60)))
            if getPropertyFromGroup('playerStrums', i, 'x') > screenWidth then 
                setPropertyFromGroup('playerStrums', i, 'x', 0 - getPropertyFromGroup('playerStrums', i, 'width'))
            end
        end
    end

    if curBeat >= 968 and curBeat <= 982 then --пока идет парт ноты летают
        for i =0,3 do
            setPropertyFromGroup('strumLineNotes', i, 'y',  _G['defaultOpponentStrumY'..i] + 10 *math.cos((currentBeatAlt + i*0.25) * math.pi))
            setPropertyFromGroup('strumLineNotes', i + 4, 'y',  _G['defaultPlayerStrumY'..i] + 10 *math.cos((currentBeatAlt + i*0.25) * math.pi))
        end
    end

    if curBeat >= 1024 and curBeat <= 1055 or curBeat >= 1088 and curBeat <= 1103 then --ХАРД СТАЙЛ
        for i = 0,3 do
            local noteX = 120 * i
            local offsetX = 320
            local thingy = 1
            if curBeat % 2 == 0 then
              thingy = -1
            end
            setPropertyFromGroup("strumLineNotes", i + 4, "y", defaultPlayerStrumY0+(math.sin((getSongPosition()-getPropertyFromClass('backend.ClientPrefs','data.noteOffset')) / crochet + (noteX-120)*2) * staticArrowWave + staticArrowWave * 0.5))
      
            setPropertyFromGroup("strumLineNotes", i + 4, "x", getPropertyFromGroup('strumLineNotes', 0, 'x')+noteX+offsetX+(thingy*staticArrowWave)*0.7)
          end
          staticArrowWave = lerp(staticArrowWave,0,elapsed*8)
    end

    if curBeat >= 1136 and curBeat <= 1163 then --перец манипулирует и ноты вообще да
        for i = 0,3 do
			setPropertyFromGroup('strumLineNotes', i, 'x',  _G['defaultOpponentStrumX'..i] + 10 *math.sin((currentBeatAlt + i*0.25) * math.pi))
            setPropertyFromGroup('strumLineNotes', i+4, 'x',  _G['defaultPlayerStrumX'..i] + 10 *math.sin((currentBeatAlt + i*0.25) * math.pi))

			setPropertyFromGroup('strumLineNotes', i, 'y', _G['defaultOpponentStrumY'..i] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
            setPropertyFromGroup('strumLineNotes', i+4, 'y',  _G['defaultPlayerStrumY'..i] + 10 *math.cos((currentBeat + i*0.25) * math.pi))
		end
    end

    if curBeat >= 1268 and curBeat <= 1299 or curBeat >= 1333 and curBeat <= 1363 or curBeat >= 1396 and curBeat <= 1427 then --ХАРД СТАЙЛ
        for i = 0,3 do
            local noteX = 120 * i
            local offsetX = 320
            local thingy = 1
            if curBeat % 2 == 0 then
              thingy = -1
            end
            setPropertyFromGroup("strumLineNotes", i + 4, "y", defaultPlayerStrumY0+(math.sin((getSongPosition()-getPropertyFromClass('backend.ClientPrefs','data.noteOffset')) / crochet + (noteX-120)*2) * staticArrowWave + staticArrowWave * 0.5))
      
            setPropertyFromGroup("strumLineNotes", i + 4, "x", getPropertyFromGroup('strumLineNotes', 0, 'x')+noteX+offsetX+(thingy*staticArrowWave)*0.7)
          end
          staticArrowWave = lerp(staticArrowWave,0,elapsed*8) 
    end

    if shitScroll then
        for i=0, getProperty('notes.length')-1 do
            dy = getPropertyFromGroup('notes', i, 'distance')
            if getPropertyFromGroup('notes', i, 'isSustainNote') == true then
                setPropertyFromGroup('notes', i, 'offsetY', -dy*2)
            elseif getPropertyFromGroup('notes', i, 'sustainLength') == 0 then
            else
                setPropertyFromGroup('notes', i, 'offsetY', -dy*2)
            end
        end
    end

    if songPosFinal >= 622852 then
        if songPosFinal < 681656 then
            if luaSpriteExists('StrumMoviment') then
                strumMovimentForce = getProperty('StrumMoviment.x')
            end
            for strums = 0,3 do
                local posY = 50
                if downscroll then
                    posY = screenHeight - 150
                end
                posY = posY + (30 *math.sin(((songPosFinal - 58033)/bpm/10 - (1.2*(3-strums))))* strumMovimentForce)
                setPropertyFromGroup('playerStrums',strums,'y',posY)
                setPropertyFromGroup('opponentStrums',strums,'y',posY)
            end
        end
    end
end

function opponentNoteHit(membersIndex, noteData, noteType, isSustainNote) --для шайки не было зомби перца
    if curBeat >= 573 and curBeat <= 579 then
        funni(getRandomFloat(15, 25))
    end

    if curBeat >= 588 and curBeat <= 595 then
        if not isSustainNote then scaleHitNote(noteData) end
    end

    if curBeat >= 596 and curBeat <= 603 then
        if noteData == 0 then
            setPropertyFromGroup('opponentStrums', 0, 'x',  _G['defaultOpponentStrumX0'] - 30)
            noteTweenX('leftoP', 0, _G['defaultOpponentStrumX0'], 0.5, 'quadOut')
        end
        if noteData == 1 then
            setPropertyFromGroup('opponentStrums', 1, 'y',  _G['defaultOpponentStrumY1'] + 30)
            noteTweenY('downoP', 1, _G['defaultOpponentStrumY1'], 0.5, 'quadOut')
        end
        if noteData == 2 then
            setPropertyFromGroup('opponentStrums', 2, 'y',  _G['defaultOpponentStrumY2'] - 30)
            noteTweenY('upoP', 2, _G['defaultOpponentStrumY2'], 0.5, 'quadOut')
        end
        if noteData == 3 then
            setPropertyFromGroup('opponentStrums', 3, 'x',  _G['defaultOpponentStrumX3'] + 30)
            noteTweenX('rightoP', 3, _G['defaultOpponentStrumX3'], 0.5, 'quadOut')
        end
    end
end

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote) --для шайки не было зомби перца
    if curBeat >= 573 and curBeat <= 587 or curBeat >= 589 and curBeat <= 595 then
        funni(getRandomFloat(15, 25))
    end

    if curBeat >= 588 and curBeat <= 595 then
        if not isSustainNote then scaleHitNote(noteData + 4) end
    end

    if curBeat >= 596 and curBeat <= 603 then
        if noteData == 0 then
            setPropertyFromGroup('playerStrums', 0, 'x',  _G['defaultPlayerStrumX0'] - 30)
            noteTweenX('leftP', 4, _G['defaultPlayerStrumX0'], 0.5, 'quadOut')
        end
        if noteData == 1 then
            setPropertyFromGroup('playerStrums', 1, 'y',  _G['defaultPlayerStrumY1'] + 30)
            noteTweenY('downP', 5, _G['defaultPlayerStrumY1'], 0.5, 'quadOut')
        end
        if noteData == 2 then
            setPropertyFromGroup('playerStrums', 2, 'y',  _G['defaultPlayerStrumY2'] - 30)
            noteTweenY('upP', 6, _G['defaultPlayerStrumY2'], 0.5, 'quadOut')
        end
        if noteData == 3 then
            setPropertyFromGroup('playerStrums', 3, 'x',  _G['defaultPlayerStrumX3'] + 30)
            noteTweenX('rightP', 7, _G['defaultPlayerStrumX3'], 0.5, 'quadOut')
        end
    end
end

function onStepHit()
    if curStep >= 184 and curStep < 191 then --ОППОНЕНТ ПРИСОЕДЕНЯЕТСЯ
        setTextString('playerWait', 'PLAYER 1\nCONNECTED')
        if balls then
            setProperty('playerWait.visible', false)
        else
            setProperty('playerWait.visible', true)
        end

        balls = not balls
    end

    if curStep == 184 then --оно
        setPropertyFromGroup('strumLineNotes', 0, 'visible', true)
    end

    if curStep == 186 then --идет
        setPropertyFromGroup('strumLineNotes', 1, 'visible', true)
    end

    if curStep == 188 then --очень
        setPropertyFromGroup('strumLineNotes', 2, 'visible', true)
    end

    if curStep == 190 then --щас
        setPropertyFromGroup('strumLineNotes', 3, 'visible', true)
    end

    if curStep == 192 then --враг готов
        setProperty('playerWait.visible', false)
    end

    if curStep == 252 then --НАЧАЛ ЕБАШИТЬ
        for i = 0, 7 do
            noteSquish(i, 'x', 2, 0.5)
            noteSquish(i, 'y', 2, 0.5)
            setPropertyFromGroup('strumLineNotes', i, 'angle', 360)
            noteTweenAngle("note"..i, i, 0, 0.3, "quadOut")
        end
    end

    for i = 0, 7 do --ПРИ ЗВУКАХ ПАУЗЫ ИЗ ПВЗ
        if curStep == 636 or curStep == 700 or curStep == 764 then --лефт
            setPropertyFromGroup('strumLineNotes', i, 'angle', -45)
        end
    
        if curStep == 638 or curStep == 702 or curStep == 766 then --райт
            setPropertyFromGroup('strumLineNotes', i, 'angle', 45)
        end
    
        if curStep == 640 or curStep == 704 or curStep == 768 then --впизду
            noteTweenAngle("note"..i, i, 360, 0.3, "backOut")
        end
    
        if curStep == 826 then --чтоб прокрутка хорошо
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
        end
        
        if curStep == 828 then --И
            noteTweenAngle("note"..i, i, -45, 0.5, "quadOut")
        end
    
        if curStep == 832 then --Ты не ебешь нас брутал ебешь нас круток
            noteTweenAngle("note"..i, i, 360, 1, "expoOut")
        end
    end

    if curStep == 1392 then --чтоб прокрутка хорошо
        for i = 0,7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
        end
    end

    --АХХ ЭХХ У И АХХ
    if curStep == 1520 or curStep == 1524 or curStep == 1528 or curStep == 1530 or curStep == 1532 or curStep == 1552 or curStep == 1556 or curStep == 1560 or curStep == 1562 or curStep == 1564 then --АА ЭЭ У И ААХ~
        staticArrowWave = 120

        if balls then
            for i = 0, 7 do
                noteSquish(i, 'x', 2, 0.3)

                setPropertyFromGroup('strumLineNotes', i, 'angle', 30)
                noteTweenAngle("angleLeft"..i, i, 0, 0.2, "quadOut")
            end
        else
            for i = 0, 7 do
                noteSquish(i, 'y', 2, 0.3)

                setPropertyFromGroup('strumLineNotes', i, 'angle', -30)
                noteTweenAngle("angleRight"..i, i, 0, 0.2, "quadOut")
            end
        end

        triggerEvent('Add Camera Zoom')

        balls = not balls
    end

    if curStep >= 1536 and curStep < 1551 then --тряска во втором парте хард стайля
		funni(16)
	end

    if curStep == 1584 then --ВРАГ ЕБОШИТ АХХХ ОХХХ ААА
        for i = 4,7 do 
            setPropertyFromGroup('strumLineNotes', i, 'x', _G["defaultPlayerStrumX"..i - 4])
            setPropertyFromGroup('strumLineNotes', i, 'y', _G["defaultPlayerStrumY"..i - 4])
        end

        noteSquish(5, 'x', 4, 0.3)
        noteSquish(5, 'y', 4, 0.3)

        noteSquish(7, 'x', 4, 0.3)
        noteSquish(7, 'y', 4, 0.3)
    end

    if curStep == 1590 then
        noteSquish(4, 'x', 4, 0.3)
        noteSquish(4, 'y', 4, 0.3)

        noteSquish(5, 'x', 4, 0.3)
        noteSquish(5, 'y', 4, 0.3)
    end

    if curStep == 1596 then
        noteSquish(5, 'x', 4, 0.3)
        noteSquish(5, 'y', 4, 0.3)

        noteSquish(6, 'x', 4, 0.3)
        noteSquish(6, 'y', 4, 0.3)
    end

    if curStep == 1600 then --ВРАГ размер ХАРД СТАЙЛ
        for i = 0, 7 do
            noteSquish(i, 'x', 4, 1)
            noteSquish(i, 'y', 4, 1)
        end
    end

    if curStep == 1604 then --ВРАГ круток ХАРД СТАЙЛ
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
            noteTweenAngle("note"..i, i, 360, 0.3, "elasticOut")
        end
    end

    if curStep == 1608 then --ВРАГ ноты лево право ХАРД СТАЙЛ
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
        end

        noteTweenX('note4', 4, _G["defaultPlayerStrumX0"] - 50, 0.3, 'elasticOut')
        noteTweenX('note5', 7, _G["defaultPlayerStrumX3"] + 50, 0.3, 'elasticOut')
    end

    if curStep == 1612 then --ВРАГ ноты вверх вниз ХАРД СТАЙЛ
        noteTweenX('note4back', 4, _G["defaultPlayerStrumX0"], 0.3, 'elasticOut')
        noteTweenX('2231', 7, _G["defaultPlayerStrumX3"], 0.3, 'elasticOut')

        noteTweenY('444', 5, _G["defaultPlayerStrumY1"] + 50, 0.3, 'elasticOut')
        noteTweenY('4444', 6, _G["defaultPlayerStrumY2"] - 50, 0.3, 'elasticOut')
    end

    if curStep == 1616 then --ВРАГ ВТОРОЙ ЕБОШИТ АХХХ ОХХХ ААА
        noteTweenY('444', 5, _G["defaultPlayerStrumY1"], 0.5, 'elasticOut')
        noteTweenY('4444', 6, _G["defaultPlayerStrumY2"], 0.5, 'elasticOut')

        noteSquish(5, 'x', 4, 0.3)
        noteSquish(5, 'y', 4, 0.3)

        noteSquish(4, 'x', 4, 0.3)
        noteSquish(4, 'y', 4, 0.3)
    end

    if curStep == 1622 then
        noteSquish(4, 'x', 4, 0.3)
        noteSquish(4, 'y', 4, 0.3)

        noteSquish(7, 'x', 4, 0.3)
        noteSquish(7, 'y', 4, 0.3)
    end

    if curStep == 1628 then
        noteSquish(4, 'x', 4, 0.3)
        noteSquish(4, 'y', 4, 0.3)

        noteSquish(6, 'x', 4, 0.3)
        noteSquish(6, 'y', 4, 0.3)
    end

    if curStep == 1632 then --ВРАГ НОТЫ НАХУЙ ХАРД СТАЙЛ
        noteTweenX('22', 4, _G["defaultPlayerStrumX0"] - 50, 1, 'circOut')
        noteTweenX('223', 7,_G["defaultPlayerStrumX3"] + 50, 1, 'circOut')

        noteTweenY('444', 5, _G["defaultPlayerStrumY1"] + 50, 1, 'circOut')
        noteTweenY('4444', 6, _G["defaultPlayerStrumY2"] + 50, 1, 'circOut')
    end

    if curStep == 1640 then --ВРАГ НОТЫ ВЕРНУЛИСЬ ХАРД СТАЙЛ
        noteTweenX('22', 4, _G["defaultPlayerStrumX0"], 0.7, 'circIn')
        noteTweenX('223', 7, _G["defaultPlayerStrumX3"], 0.7, 'circIn')

        noteTweenY('444', 5, _G["defaultPlayerStrumY1"], 0.7, 'circIn')
        noteTweenY('4444', 6, _G["defaultPlayerStrumY2"], 0.7, 'circIn')
    end

    if curStep == 1648 then --ИГРОК ЕБОШИТ АХХХ ОХХХ ААА
        noteSquish(5, 'x', 4, 0.3)
        noteSquish(5, 'y', 4, 0.3)

        noteSquish(7, 'x', 4, 0.3)
        noteSquish(7, 'y', 4, 0.3)
    end

    if curStep == 1654 then
        noteSquish(5, 'x', 4, 0.3)
        noteSquish(5, 'y', 4, 0.3)
    end

    if curStep == 1660 then
        noteSquish(5, 'x', 4, 0.3)
        noteSquish(5, 'y', 4, 0.3)

        noteSquish(6, 'x', 4, 0.3)
        noteSquish(6, 'y', 4, 0.3)
    end

    if curStep == 1664 then --ИГРОК размер ХАРД СТАЙЛ
        for i = 0, 7 do
            noteSquish(i, 'x', 4, 1)
            noteSquish(i, 'y', 4, 1)
        end
    end

    if curStep == 1668 then --ИГРОК круток ХАРД СТАЙЛ
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
            noteTweenAngle("note"..i, i, 360, 0.5, "quadOut")
        end
    end

    if curStep == 1672 then --ИГРОК ноты лево право ХАРД СТАЙЛ
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
        end

        noteTweenX('note4', 4, _G["defaultPlayerStrumX0"] - 50, 0.3, 'elasticOut')
        noteTweenX('note5', 7, _G["defaultPlayerStrumX3"] + 50, 0.3, 'elasticOut')
    end

    if curStep == 1676 then --ИГРОК ноты вверх вниз ХАРД СТАЙЛ
        noteTweenX('note4back', 4, _G["defaultPlayerStrumX0"], 0.3, 'elasticOut')
        noteTweenX('2231', 7, _G["defaultPlayerStrumX3"], 0.3, 'elasticOut')

        noteTweenY('444', 5, _G["defaultPlayerStrumY1"] + 50, 0.3, 'elasticOut')
        noteTweenY('4444', 6, _G["defaultPlayerStrumY2"] - 50, 0.3, 'elasticOut')
    end

    if curStep == 1680 then --ИГРОК ВТОРОЙ ЕБОШИТ АХХХ ОХХХ ААА
        noteTweenY('444', 5, _G["defaultPlayerStrumY1"], 0.5, 'elasticOut')
        noteTweenY('4444', 6, _G["defaultPlayerStrumY2"], 0.5, 'elasticOut')

        noteSquish(5, 'x', 4, 0.3)
        noteSquish(5, 'y', 4, 0.3)

        noteSquish(4, 'x', 4, 0.3)
        noteSquish(4, 'y', 4, 0.3)
    end

    if curStep == 1686 then
        noteSquish(4, 'x', 4, 0.3)
        noteSquish(4, 'y', 4, 0.3)

        noteSquish(7, 'x', 4, 0.3)
        noteSquish(7, 'y', 4, 0.3)
    end

    if curStep == 1692 then
        noteSquish(4, 'x', 4, 0.3)
        noteSquish(4, 'y', 4, 0.3)

        noteSquish(6, 'x', 4, 0.3)
        noteSquish(6, 'y', 4, 0.3)
    end

    if curStep == 1696 then --ИГРОК НАХУЙ НОТЫ ХАРД СТАЙЛ
        noteTweenX('22', 4, _G["defaultPlayerStrumX0"] - 50, 1, 'circOut')
        noteTweenX('223', 7,_G["defaultPlayerStrumX3"] + 50, 1, 'circOut')

        noteTweenY('444', 5, _G["defaultPlayerStrumY1"] + 50, 1, 'circOut')
        noteTweenY('4444', 6, _G["defaultPlayerStrumY2"] + 50, 1, 'circOut')
    end

    if curStep == 1704 then  --ИГРОК ОБРАТНО НОТЫ ХАРД СТАЙЛ
        noteTweenX('22', 4, _G["defaultPlayerStrumX0"], 0.7, 'circIn')
        noteTweenX('223', 7, _G["defaultPlayerStrumX3"], 0.7, 'circIn')

        noteTweenY('444', 5, _G["defaultPlayerStrumY1"], 0.7, 'circIn')
        noteTweenY('4444', 6, _G["defaultPlayerStrumY2"], 0.7, 'circIn')
    end
end

local ofs = 100
function onBeatHit()
    if curBeat >= 32 and curBeat <= 45 then --ожидание оппонента
        if balls then
            setProperty('playerWait.visible', false)
        else
            setProperty('playerWait.visible', true)
        end

        balls = not balls
    end

    if curBeat >= 64 and curBeat <= 126 then --Начало танцуют углами
        if balls then
            for i = 0, 7 do
                noteSquish(i, 'x', 2, 0.3)

                setPropertyFromGroup('strumLineNotes', i, 'angle', 30)
                noteTweenAngle("angleLeft"..i, i, 0, 0.2, "quadOut")
            end
        else
            for i = 0, 7 do
                noteSquish(i, 'y', 2, 0.3)

                setPropertyFromGroup('strumLineNotes', i, 'angle', -30)
                noteTweenAngle("angleRight"..i, i, 0, 0.2, "quadOut")
            end
        end

        balls = not balls

        if curBeat >= 96 and curBeat <= 126 then --Начало танцуют вверх и вниз
            if dance then
                for i=0,3 do
                    if i % 2 == 0 then
                        noteTweenY('y'..i, i, _G['defaultOpponentStrumY'..i] + 30, 0.5, 'elasticOut')
                        noteTweenY('y'..i + 4, i + 4, _G['defaultPlayerStrumY'..i] + 30, 0.5, 'elasticOut')
                    else
                        noteTweenY('y'..i, i, _G['defaultOpponentStrumY'..i] - 30, 0.5, 'elasticOut')
                        noteTweenY('y'..i + 4, i + 4, _G['defaultPlayerStrumY'..i] - 30, 0.5, 'elasticOut')
                    end
                end
            else
                for i=0,3 do
                    if i % 2 == 0 then
                        noteTweenY('y'..i, i, _G['defaultOpponentStrumY'..i] - 30, 0.5, 'elasticOut')
                        noteTweenY('y'..i + 4, i + 4, _G['defaultPlayerStrumY'..i] - 30, 0.5, 'elasticOut')
                    else
                        noteTweenY('y'..i, i, _G['defaultOpponentStrumY'..i] + 30, 0.5, 'elasticOut')
                        noteTweenY('y'..i + 4, i + 4, _G['defaultPlayerStrumY'..i] + 30, 0.5, 'elasticOut')
                    end
                end
            end
    
            dance = not dance
        end
    end

    if curBeat == 127 then --МЫ МЫ БРУТАЛ ЭКС НЕ ЕБЕШЩЬ БРУТАЛ ЭКС
        for i=0,3 do
            noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'elasticOut')
            noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'elasticOut')
        end

        for i=0,7 do
            noteSquish(i, 'x', 2, 0.5)
            noteSquish(i, 'y', 2, 0.5)
            setPropertyFromGroup('strumLineNotes', i, 'angle', 360)
            noteTweenAngle("note"..i, i, 0, 0.3, "quadOut")
        end
    end

    if curBeat == 135 then --Хуяк
        for i=0,7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 360)
            noteTweenAngle("note"..i, i, 0, 0.3, "quadOut")
        end
    end

    if curBeat >= 136 and curBeat <= 143 then --Биты размер не ебет брутал секс
        for i=0,7 do
            noteSquish(i, 'x', 2, 0.5)
            noteSquish(i, 'y', 2, 0.5)
        end
    end

    if curBeat == 143 then --в обратное положение
        for i=0,3 do
            noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'elasticOut')
            noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'elasticOut')

            noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 0.5, 'elasticOut')
            noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 0.5, 'elasticOut')
        end

        for i=0,7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 360)
            noteTweenAngle("note"..i, i, 0, 0.3, "quadOut")
        end
    end

    if curBeat == 144 then --Меняет направление нот плавно
        runTimer('direct', 3, 0)
		for i = 0,7 do
            startTween('noteDirect'..i, 'strumLineNotes.members['..i..']', {direction = 70}, 3)
		end
    end

    if curBeat == 207 then --в пизду щас будет
		for i = 0,7 do
            noteSquish(i, 'x', 4, 0.5)
            noteSquish(i, 'y', 4, 0.5)
		end
    end

    if curBeat >= 144 and curBeat <= 206 then --Пока направление меняется, уебки танцует пиздато
        if balls then
            for i=0,3 do
                scaleShit = i + 4
                if i % 2 == 0 then
                    doTweenX('noteSquishx'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleX + 1.0, 0.3, 'elasticOut')
                    doTweenX('noteSquishx'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleX + 1.0, 0.3, 'elasticOut')

                    doTweenY('noteSquishy'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleY - 1.0, 0.3, 'elasticOut')
                    doTweenY('noteSquishy'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleY - 1.0, 0.3, 'elasticOut')
                else
                    doTweenX('noteSquishx'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleX - 1.0, 0.3, 'elasticOut')
                    doTweenX('noteSquishx'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleX - 1.0, 0.3, 'elasticOut')

                    doTweenY('noteSquishy'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleY + 1.0, 0.3, 'elasticOut')
                    doTweenY('noteSquishy'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleY + 1.0, 0.3, 'elasticOut')
                end
            end
        else
            for i=0,3 do
                scaleShit = i + 4
                if i % 2 == 0 then
                    doTweenX('noteSquishx'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleX - 1.0, 0.3, 'elasticOut')
                    doTweenX('noteSquishx'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleX - 1.0, 0.3, 'elasticOut')

                    doTweenY('noteSquishy'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleY + 1.0, 0.3, 'elasticOut')
                    doTweenY('noteSquishy'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleY + 1.0, 0.3, 'elasticOut')
                else
                    doTweenX('noteSquishx'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleX + 1.0, 0.3, 'elasticOut')
                    doTweenX('noteSquishx'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleX + 1.0, 0.3, 'elasticOut')

                    doTweenY('noteSquishy'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleY - 1.0, 0.3, 'elasticOut')
                    doTweenY('noteSquishy'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleY - 1.0, 0.3, 'elasticOut')
                end
            end
        end

        balls = not balls
    end

    if curBeat == 215 or curBeat == 231 or curBeat == 247 or curBeat == 263 then --ТЫ НЕ ЕБЕШЬ НАС, БРУТАЛ ЕБЕШЬ НАС
        for i=0,3 do
            noteTweenY('goUp'..i, i, _G['defaultOpponentStrumY'..i] - 25, 0.4, 'quadOut')
            noteTweenY('goUp'..i + 4, i + 4, _G['defaultPlayerStrumY'..i]- 25, 0.4, 'quadOut')
    
            noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 0.3, 'elasticOut')
            noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 0.3, 'elasticOut')
        end
    end

    if curBeat == 224 or curBeat == 240 or curBeat == 256 then --После конца секции МЫ МЫ БРУТАЛ ЭКС
        for i=0,7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 360)
            noteTweenAngle("note"..i, i, 0, 0.3, "quadOut")
        end
    end
    
    if curBeat >= 216 and curBeat <= 224 or curBeat >= 232 and curBeat <= 240 or curBeat >= 248 and curBeat <= 256 then ----МЫ МЫ БРУТАЛ ЭКС МЫ МЫ БРУТАЛ ЭКС 
        for i=0,3 do
            setPropertyFromGroup('strumLineNotes', i, 'y',  _G['defaultOpponentStrumY'..i] + 30)
            setPropertyFromGroup('strumLineNotes', i + 4, 'y',  _G['defaultPlayerStrumY'..i] + 30)

            noteTweenY('dance'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'quadOut')
            noteTweenY('dance'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'quadOut')
        end
    end

    if curBeat >= 264 and curBeat <= 271 then ----МЫ МЫ БРУТАЛ ЭКС МЫ МЫ БРУТАЛ ЭКС ПОСЛЕДНИЙ
        for i=0,3 do
            setPropertyFromGroup('strumLineNotes', i, 'y',  _G['defaultOpponentStrumY'..i] + 30)
            setPropertyFromGroup('strumLineNotes', i + 4, 'y',  _G['defaultPlayerStrumY'..i] + 30)

            noteTweenY('dance'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'quadOut')
            noteTweenY('dance'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'quadOut')
        end

        if balls then
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', 30)
                noteTweenAngle("angleLeft"..i, i, 0, 0.2, "quadOut")
            end
        else
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', -30)
                noteTweenAngle("angleRight"..i, i, 0, 0.2, "quadOut")
            end
        end

        balls = not balls
    end

    if curBeat == 272 then --Перемена
        for i=0,3 do
            setPropertyFromGroup('strumLineNotes', i, 'y',  _G['defaultOpponentStrumY'..i] + 50)
            setPropertyFromGroup('strumLineNotes', i + 4, 'y',  _G['defaultPlayerStrumY'..i] + 50)

            noteTweenY('dance'..i, i, _G['defaultOpponentStrumY'..i], 1.5, 'quadOut')
            noteTweenY('dance'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 1.5, 'quadOut')
        end

        for i = 0, 7 do
            noteTweenAngle("note"..i, i, 360, 1, "quadOut")
        end
    end

    if curBeat == 288 then --Ща ебанет
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
            noteTweenAngle("note"..i, i, 360, 1, "quadOut")
        end
    end

    if curBeat == 300 then --Круток послдений
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
            noteTweenAngle("note"..i, i, -360, 3, "expoInOut")
        end
    end
    
    if curBeat >= 304 and curBeat < 336 then --парт перед пиздецом
        funni(32)

        if balls then
            for i = 0, 7 do
                noteSquish(i, 'x', 2, 0.3)
            end
        else
            for i = 0, 7 do
                noteSquish(i, 'y', 2, 0.3)
            end
        end

        balls = not balls
    end

    if curBeat == 336 then --ну все
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
        end
    end

    if curBeat == 344 then --ТЫ
        for i = 0, 3 do
            noteTweenAlpha('CANNOT'..i, i, 0, 0.3)
        end

        doTweenAlpha('herBar', 'healthBar', 0, 1)
        doTweenAlpha('herBarBG', 'healthBarBGOverlay', 0, 1)
        doTweenAlpha('iconP1', 'iconP1', 0, 1)
        doTweenAlpha('iconP2', 'iconP2', 0, 1)

        noteTweenAngle("saltoHWAW1", 4, -360, 0.3, "elasticOut");
        if not middlescroll then noteTweenX('foxTween1', 4, 415 + Meow1, 0.3, 'elasticOut'); end
    end

    if curBeat == 345 then --НЕ
        setProperty('updateTime', false)
        setProperty('timeTxt.text', 'YOU CANNOT FUCK US')

        noteTweenAngle("saltoHWAW2", 5, -360, 0.3, "elasticOut");
        if not middlescroll then noteTweenX('foxTween2', 5, 415 + Meow2, 0.3, 'elasticOut'); end
    end

    if curBeat == 346 then --ЕБЕШЬ
        noteTweenAngle("saltoHWAW3", 6, -360, 0.3, "elasticOut");
        if not middlescroll then noteTweenX('foxTween3', 6, 415 + Meow3, 0.3, 'elasticOut'); end
    end

    if curBeat == 347 then --НАС
        noteTweenAngle("saltoHWAW4", 7, -360, 0.3, "elasticOut");
        if not middlescroll then noteTweenX('foxTween4', 7, 415 + Meow4, 0.3, 'elasticOut'); end
    end

    if curBeat == 388 then --yk
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 0)
        end
    end

    if curBeat >= 392 and curBeat < 396 then --последний парт 2
        if balls then
            for i = 0, 7 do
                noteSquish(i, 'x', 3, 0.3)

                setPropertyFromGroup('strumLineNotes', i, 'angle', 25)
                noteTweenAngle("angleLeft"..i, i, 0, 0.2, "quadOut")
            end
        else
            for i = 0, 7 do
                noteSquish(i, 'y', 3, 0.3)

                setPropertyFromGroup('strumLineNotes', i, 'angle', -25)
                noteTweenAngle("angleRight"..i, i, 0, 0.2, "quadOut")
            end
        end

        balls = not balls
    end

    if curBeat == 427 then --переход ко второй волне
        for i = 4, 7 do
            noteTweenAngle("trans"..i, i, -30, 0.5, "quadOut");
        end
    end

    if curBeat == 428 then --WAVE 2 начало
        setProperty('updateTime', true)

        runHaxeCode([[
            FlxTween.tween(game, {songLength: (306 * 1000)}, 4, {ease: FlxEase.smootherStepInOut});
       ]]);

        doTweenAlpha('herBar', 'healthBar', 1, 1)
        doTweenAlpha('herBarBG', 'healthBarBGOverlay', 1, 1)
        doTweenAlpha('iconP1', 'iconP1', 1, 1)
        doTweenAlpha('iconP2', 'iconP2', 1, 1)

        for i = 0, 3 do
            noteTweenX('movePlayer'..i + 4, i + 4, _G["initDefaultPlayerStrumX"..i], 1, "quadOut")
            noteTweenAngle("poleAngle"..i + 4, i + 4, 360, 1, "quadOut")

            if middlescroll then
                noteTweenAlpha('CANT'..i, i, 0.35, 1) 
            else
                noteTweenAlpha('CANT'..i, i, 1, 1) 
            end
        end      
    end

    if curBeat == 460 then --SCROLL MOMENTS
        scrollChange("elasticOut")
    end

    if curBeat >= 477 and curBeat <= 505 then --типа в начале под бит yk
        if curBeat % 2 == 0 then
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', 45)
                noteTweenAngle("note"..i, i, 0, 0.5, "quartOut")
            end
        end
    end

    if curBeat == 507 then  --SCROLL MOMENTS
        scrollChange("expoOut")

        for i = 0, 3 do
            noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 0.5, 'quadOut')
            noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 0.5, 'quadOut')
        end
    end

    if curBeat >= 507 and curBeat <= 523 or curBeat >= 525 and curBeat <= 539 then --Творят жесть после первого партишки

        for i = 0, 7 do
            noteSquish(i, 'x', 2, 0.3)
            noteSquish(i, 'y', 2, 0.3)
        end

        if balls then
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', 30)
                noteTweenAngle("angleLeft"..i, i, 0, 0.2, "quadOut")
            end
        else
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', -30)
                noteTweenAngle("angleRight"..i, i, 0, 0.2, "quadOut")
            end
        end

        balls = not balls
    end

    if curBeat == 507 or curBeat == 524 then --Круток
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', -360)
            noteTweenAngle("note"..i, i, 0, 0.6, "backOut")
        end
    end

    if curBeat == 524 then --SCROLL MOMENTS
        scrollChange("quadOut")
    end

    if curBeat == 540 then --SCROLL MOMENTS
        scrollChange("elasticOut")
    end

    if curBeat == 556 then --ВРУУУУММММ
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', -360)
            noteTweenAngle("note"..i, i, 0, 0.5, "sineOut")
        end
    end

    if curBeat >= 557 and curBeat <= 572 then --в моменте где видео крутят размер и тд короче ухх

        for i = 0, 7 do
            noteSquish(i, 'x', 2, 0.3)
            noteSquish(i, 'y', 2, 0.3)
        end

        if balls then
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', 30)
                noteTweenAngle("angleLeft"..i, i, 0, stepCrochet * 0.0038, "expoIn")
            end
        else
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', -30)
                noteTweenAngle("angleRight"..i, i, 0, stepCrochet * 0.0038, "expoIn")
            end
        end

        balls = not balls
    end

    if curBeat == 572 then --ты понял уже
        scrollChange("elasticOut")

        for i = 0, 3 do
            noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 0.5, 'quadOut')
            noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 0.5, 'quadOut')
        end
    end

    if curBeat == 588 then --да да да
        scrollChange("elasticOut")
    end

    if curBeat >= 608 and curBeat <= 675 then --ноты после парта с видео туда сюда
        if curBeat % 2 == 1 then
            if middlescroll then
                for i = 0, 3 do
                    if l then
                        setPropertyFromGroup('strumLineNotes', i+4, 'x',  _G['defaultPlayerStrumX'..i] - 75)
                        noteTweenX('wigle'..i+4, i+4, _G['defaultPlayerStrumX'..i], 0.3, 'quadOut')
                    else
                        setPropertyFromGroup('strumLineNotes', i+4, 'x',  _G['defaultPlayerStrumX'..i] + 75)
                        noteTweenX('wigleBack'..i+4, i+4, _G['defaultPlayerStrumX'..i], 0.3, 'quadOut')
                    end
                end
            else
                if l then
                    wiggleThing = -250--WIGGLE_AMPLITUDE
                else
                    wiggleThing = 250--WIGGLE_AMPLITUDE
                end
            end

            l = not l
        end
    end


    if curBeat == 612 then --ага
        scrollChange("elasticOut")
    end

    if curBeat == 644 then --i wish lua had cases or whatever...
        scrollChange("elasticOut")
    end

    if curBeat == 676 then --я щас слушаю bad apple кста
        scrollChange("elasticOut")
    end

    if curBeat >= 692 and curBeat <= 707 then --перец манипуляция и происхоит пиздец
        upShit = 40

        for i = 0, 7 do
            noteSquish(i, 'x', 2, 0.3)
            noteSquish(i, 'y', 2, 0.3)
        end
    end

    if curBeat == 707 then --вот опять мы тут
        scrollChange("elasticOut")
    end

    if curBeat == 708 then --ноты в одно нах
        noteTweenX('foxTween12', 5, _G['defaultPlayerStrumX1'] + 25, 0.8, 'elasticOut');
		noteTweenX('foxTween22', 4, _G['defaultPlayerStrumX1'] + 25 , 0.8, 'elasticOut');
		noteTweenX('foxTween32', 6, _G['defaultPlayerStrumX1'] + 25, 0.8, 'elasticOut');
		noteTweenX('foxTween42', 7, _G['defaultPlayerStrumX1'] + 25, 0.8, 'elasticOut');

        noteTweenX('foxTween1', 1, _G['defaultOpponentStrumX1'] + 25, 0.8, 'elasticOut');
		noteTweenX('foxTween2', 0, _G['defaultOpponentStrumX1'] + 25, 0.8, 'elasticOut');
		noteTweenX('foxTween3', 2, _G['defaultOpponentStrumX1'] + 25, 0.8, 'elasticOut');
		noteTweenX('foxTween4', 3, _G['defaultOpponentStrumX1'] + 25, 0.8, 'elasticOut');
    end

    if curBeat == 724 then --ноты flip или как там
        for i=0,3 do
            noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'elasticOut')
            noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.4, 'elasticOut')
        end

        noteTweenX('foxTween1', 4, _G['defaultPlayerStrumX3'], 0.4, 'elasticOut');
        noteTweenX('foxTween2', 5, _G['defaultPlayerStrumX2'], 0.4,'elasticOut');
        noteTweenX('foxTween3', 6, _G['defaultPlayerStrumX1'], 0.4, 'elasticOut');
        noteTweenX('foxTween4', 7, _G['defaultPlayerStrumX0'], 0.4, 'elasticOut');

        noteTweenX('foxTween12', 0, _G['defaultOpponentStrumX3'], 0.4, 'elasticOut');
        noteTweenX('foxTween22', 1, _G['defaultOpponentStrumX2'],  0.4, 'elasticOut');
        noteTweenX('foxTween322', 2, _G['defaultOpponentStrumX1'], 0.4, 'elasticOut');
        noteTweenX('foxTween42', 3, _G['defaultOpponentStrumX0'], 0.4, 'elasticOut');
    end

    if curBeat == 716 or curBeat == 732 then --в боих случаях в пизду
        for i=0,3 do
            noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'elasticOut')
            noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'elasticOut')

            noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 0.5, 'elasticOut')
            noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 0.5, 'elasticOut')
        end
    end

    if curBeat >= 716 and curBeat <= 739 then --если пизда то флексим)
        if balls then
            for i=0,3 do
                scaleShit = i + 4
                if i % 2 == 0 then
                    doTweenX('noteSquishx'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleX + 1.0, 0.3, 'elasticOut')
                    doTweenX('noteSquishx'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleX + 1.0, 0.3, 'elasticOut')

                    doTweenY('noteSquishy'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleY - 1.0, 0.3, 'elasticOut')
                    doTweenY('noteSquishy'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleY - 1.0, 0.3, 'elasticOut')
                else
                    doTweenX('noteSquishx'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleX - 1.0, 0.3, 'elasticOut')
                    doTweenX('noteSquishx'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleX - 1.0, 0.3, 'elasticOut')

                    doTweenY('noteSquishy'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleY + 1.0, 0.3, 'elasticOut')
                    doTweenY('noteSquishy'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleY + 1.0, 0.3, 'elasticOut')
                end
            end

            for i=0,7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', 30)
                noteTweenAngle("angleLeft"..i, i, 0, 0.2, "quadOut")
            end
        else
            for i=0,3 do
                scaleShit = i + 4
                if i % 2 == 0 then
                    doTweenX('noteSquishx'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleX - 1.0, 0.3, 'elasticOut')
                    doTweenX('noteSquishx'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleX - 1.0, 0.3, 'elasticOut')

                    doTweenY('noteSquishy'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleY + 1.0, 0.3, 'elasticOut')
                    doTweenY('noteSquishy'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleY + 1.0, 0.3, 'elasticOut')
                else
                    doTweenX('noteSquishx'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleX + 1.0, 0.3, 'elasticOut')
                    doTweenX('noteSquishx'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleX + 1.0, 0.3, 'elasticOut')

                    doTweenY('noteSquishy'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleY - 1.0, 0.3, 'elasticOut')
                    doTweenY('noteSquishy'..i + 4, 'strumLineNotes.members['..scaleShit..'].scale', defaultScaleY - 1.0, 0.3, 'elasticOut')
                end
            end
            for i=0,7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', -30)
                noteTweenAngle("angleLeft"..i, i, 0, 0.2, "quadOut")
            end
        end

        balls = not balls
    end

    if curBeat >= 716 and curBeat <= 723 or curBeat >= 732 and curBeat <= 739 then --Все еще флексим даже так
        if dance then
            for i=0,3 do
                if i % 2 == 0 then
                    noteTweenY('y'..i, i, _G['defaultOpponentStrumY'..i] + 30, 0.5, 'elasticOut')
                    noteTweenY('y'..i + 4, i + 4, _G['defaultPlayerStrumY'..i] + 30, 0.5, 'elasticOut')
                else
                    noteTweenY('y'..i, i, _G['defaultOpponentStrumY'..i] - 30, 0.5, 'elasticOut')
                    noteTweenY('y'..i + 4, i + 4, _G['defaultPlayerStrumY'..i] - 30, 0.5, 'elasticOut')
                end
            end
        else
            for i=0,3 do
                if i % 2 == 0 then
                    noteTweenY('y'..i, i, _G['defaultOpponentStrumY'..i] - 30, 0.5, 'elasticOut')
                    noteTweenY('y'..i + 4, i + 4, _G['defaultPlayerStrumY'..i] - 30, 0.5, 'elasticOut')
                else
                    noteTweenY('y'..i, i, _G['defaultOpponentStrumY'..i] + 30, 0.5, 'elasticOut')
                    noteTweenY('y'..i + 4, i + 4, _G['defaultPlayerStrumY'..i] + 30, 0.5, 'elasticOut')
                end
            end
        end

        dance = not dance
    end

    if curBeat == 740 then --HARD STYLE TIME
        for i = 0, 3 do
            noteTweenAlpha("note"..i, i, 0, 0.5, "linear")

            noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'elasticOut')
            noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'elasticOut')
        end

        doTweenAlpha('herBar', 'healthBar', 0, 1)
        doTweenAlpha('herBarBG', 'healthBarBGOverlay', 0, 1)
        doTweenAlpha('iconP1', 'iconP1', 0, 1)
        doTweenAlpha('iconP2', 'iconP2', 0, 1)

        for i = 0,7 do
            doTweenX('noteSquishx'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleX, 0.5, 'elasticOut')
            doTweenY('noteSquishy'..i, 'strumLineNotes.members['..i..'].scale', defaultScaleY, 0.5, 'elasticOut')
        end

        if not middlescroll then
            noteTweenX('foxTween1', 4, 415 + Meow1, 1, 'quadOut');
            noteTweenX('foxTween2', 5, 415 + Meow2, 1, 'quadOut');
            noteTweenX('foxTween3', 6, 415 + Meow3, 1, 'quadOut');
            noteTweenX('foxTween4', 7, 415 + Meow4, 1, 'quadOut');
        end
    end

    if curBeat == 775 then --и...
        setProperty('updateTime', false)
        setProperty('timeTxt.text', 'YOU CANNOT FUCK US')
        
        for i = 0, 7 do
            noteTweenAngle("poleAngle"..i + 4, i + 4, 360, 0.3, "elasticOut")
        end
    end

    if curBeat >= 776 and curBeat <= 807 then --ТЫ НЕ ЕБЕШЬ НАС
        staticArrowWave = 69
    end

    if curBeat == 808 then --переход нв 3 волну
        for i = 0, 3 do
            noteTweenX('movePlayer'..i + 4, i + 4, _G["initDefaultPlayerStrumX"..i], 1, "quadOut")
            noteTweenAngle("poleAngle"..i + 4, i + 4, 360, 1, "quadOut")
            noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 1, 'quadOut')
            noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 1, 'quadOut')
            if middlescroll then
                noteTweenAlpha('CANT'..i, i, 0.35, 1) 
            else
                noteTweenAlpha('CANT'..i, i, 1, 1) 
            end
        end      

        doTweenAlpha('herBar', 'healthBar', 1, 1)
        doTweenAlpha('herBarBG', 'healthBarBGOverlay', 1, 1)
        doTweenAlpha('iconP1', 'iconP1', 1, 1)
        doTweenAlpha('iconP2', 'iconP2', 1, 1)

        setProperty('updateTime', true)
        runHaxeCode([[
            FlxTween.tween(game, {songLength: (484 * 1000)}, 4, {ease: FlxEase.backInOut});
        ]]);
    end

    if curBeat >= 840 and curBeat <= 855 or curBeat >= 872 and curBeat <= 887 then --туды сюды хуи туды ну и начало 3 волны
        for i = 0, 3 do
            noteTweenAlpha("note"..i, i, 0.35, 0.5, "linear")
        end
        if curBeat % 2 == 0 then
            turn2 = turn2 * -1
            for i = 0,7 do
                local uhhh = curBeat % 8 * (i + i)
                local swag = i % 4 * 2.5 - uhhh
                if i > 3 then
                    x =  getPropertyFromGroup('opponentStrums', i - 4, 'x');
                else
                    x =  getPropertyFromGroup('playerStrums', i, 'x');
                end
                noteTweenX("wheeeleft"..i, i, x + turn2, crochet * 0.002, "sineInOut")
            end
        end
    end

    if curBeat >= 856 and curBeat <= 918 then --БУМ
        if curBeat % 2 == 1 then
            for i = 0, 7 do
                noteSquish(i, 'x', 2, 0.87)
                noteSquish(i, 'y', 2, 0.87)

                setPropertyFromGroup('strumLineNotes', i, 'angle', getRandomFloat(-100, 100))
                noteTweenAngle("note"..i, i, 0, 0.87, "quintOut")
            end
        end
    end

    if curBeat == 856 or curBeat == 888 then --и обратно сюда
        for i = 0, 3 do
            if middlescroll then
                noteTweenAlpha('notalpha'..i, i, 0.35, 0.5) 
            else
                noteTweenAlpha('notalpha'..i, i, 1, 0.5) 
            end

            noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'elasticOut')
            noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'elasticOut')

            noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 0.5, 'elasticOut')
            noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 0.5, 'elasticOut')
        end
    end
	
	if curBeat == 872 then --Меняет направление нот плавно
        runTimer('direct3', 1, 0)
		for i = 0,7 do
            startTween('noteDirect'..i, 'strumLineNotes.members['..i..']', {direction = 70}, 1)
		end
    end

    if curBeat == 888 then --в пизду щас будет
--sex
    end
	
	if curBeat == 888 then --круток
        for i=0,7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', 360)
            noteTweenAngle("note"..i, i, 0, 0.3, "quadOut")
        end
    end

    if curBeat >= 920 and curBeat <= 951 then --ЕБЕШЬ ТЫ НЕ ЕБЕШЬ
        for i=0,3 do
            setPropertyFromGroup('strumLineNotes', i, 'y',  _G['defaultOpponentStrumY'..i] + 30)
            setPropertyFromGroup('strumLineNotes', i + 4, 'y',  _G['defaultPlayerStrumY'..i] + 30)
    
            noteTweenY('dance'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'quadOut')
            noteTweenY('dance'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'quadOut')
        end
    end

    if curBeat >= 920 and curBeat <= 982 then --ЕБЕШЬ ТЫ НЕ ЕБЕШЬ
        for i=0,7 do
            noteSquish(i, 'x', 2, 0.87)
            noteSquish(i, 'y', 2, 0.87)
        end

        if balls then
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', 30)
                noteTweenAngle("angleLeft"..i, i, 0, 0.2, "quadOut")
            end
        else
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', -30)
                noteTweenAngle("angleRight"..i, i, 0, 0.2, "quadOut")
            end
        end

        balls = not balls
    end

    if curBeat == 984 then --просто ресет
        for i=0,3 do
            noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'elasticOut')
            noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'elasticOut')

            noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 0.5, 'elasticOut')
            noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 0.5, 'elasticOut')
        end
    end

    if curBeat >= 992 and curBeat <= 1019 then --фаннни
        if curBeat % 2 == 1 then
            funni(getRandomFloat(15, 25))
        end
    end

    if curBeat == 1020 then --HARD STYLE
        if not middlescroll then
            noteTweenX('foxTween1', 4, 415 + Meow1, 1, 'cubeInOut');
            noteTweenX('foxTween2', 5, 415 + Meow2, 1, 'cubeInOut');
            noteTweenX('foxTween3', 6, 415 + Meow3, 1, 'cubeInOut');
            noteTweenX('foxTween4', 7, 415 + Meow4, 1, 'cubeInOut');
        end

        for i = 0, 3 do
            noteTweenAlpha("note"..i, i, 0, 1, "quadInOut")
        end

        doTweenAlpha('herBar', 'healthBar', 0, 1)
        doTweenAlpha('herBarBG', 'healthBarBGOverlay', 0, 1)
        doTweenAlpha('iconP1', 'iconP1', 0, 1)
        doTweenAlpha('iconP2', 'iconP2', 0, 1)
    end

    if curBeat == 1100 then
        doTweenAlpha('herBar', 'healthBar', 1, 1)
        doTweenAlpha('herBarBG', 'healthBarBGOverlay', 1, 1)
        doTweenAlpha('iconP1', 'iconP1', 1, 1)
        doTweenAlpha('iconP2', 'iconP2', 1, 1)
    end

    if curBeat >= 1024 and curBeat <= 1055 or curBeat >= 1088 and curBeat <= 1103 then --ТЫ НЕ ЕБЕШЬ НАС
        staticArrowWave = 69
    end

    if curBeat == 1131 then --просто ресет
        for i=0,3 do
            noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'backOut')
            noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'backOut')

            noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 0.5, 'backOut')
            noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 0.5, 'backOut')
        end
    end

    if curBeat == 1167 then --просто ресет
        for i=0,3 do
            noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'quadOut')
            noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'quadOut')

            noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 0.5, 'quadOut')
            noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 0.5, 'quadOut')
        end
    end

    if curBeat == 1200 then --просто ресет
        for i=0,3 do
            noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 1, 'bounceInOut')
            noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 1, 'bounceInOut')

            noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 1, 'bounceInOut')
            noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 1, 'bounceInOut')
        end

        runHaxeCode([[
            FlxTween.tween(game, {songLength: (9999 * 1000)}, 1, {ease: FlxEase.expoOut});
        ]]);
    end

    if curBeat == 1208 then --просто ресет
        runHaxeCode([[
            FlxTween.tween(game, {songLength: (583 * 1000)}, 10, {ease: FlxEase.expoIn});
        ]]);
    end

    if curBeat >= 1168 and curBeat <= 1200 then --хз че это посмотрим
        if curBeat % 4 == 0 then
            for i = 0, 7 do
                noteSquish(i, 'x', 2, 0.5)
                noteSquish(i, 'y', 2, 0.5)
            end
        end

        if curBeat % 4 == 2 then
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', 45)
                noteTweenAngle("note"..i, i, 0, 0.5, "quartOut")
            end
        end
    end

    if curBeat == 1232 then
        if not middlescroll then
            noteTweenX('sex', 4, 415 + Meow1, 1, 'cubeInOut');
            noteTweenX('sex2', 5, 415 + Meow2, 1, 'cubeInOut');
            noteTweenX('sex3', 6, 415 + Meow3, 1, 'cubeInOut');
            noteTweenX('sex5', 7, 415 + Meow4, 1, 'cubeInOut');
        end

        for i = 0, 3 do
            noteTweenAlpha("note"..i, i, 0, 1, "quadInOut")
        end
    end
    if curBeat == 1300 then
        scrollChange('elasticOut')
    end

    if curBeat == 1332 then
        InitscrollChangeFinal()
    end

    if curBeat == 1364 then
        noteTweenY('foxTween1', 4, 310, 1, 'elasticOut');
        noteTweenY('foxTween2', 5, 310, 1, 'elasticOut');
        noteTweenY('foxTween3', 6, 310, 1, 'elasticOut');
        noteTweenY('foxTween4', 7, 310, 1, 'elasticOut');

        shitScroll = true
    end

    if curBeat == 1396 then
        shitScroll = false
    end

    if curBeat >= 1268 and curBeat <= 1299 or curBeat >= 1333 and curBeat <= 1363 or curBeat >= 1396 and curBeat <= 1427 then --ХАРД СТАЙЛ
        staticArrowWave = 69
    end

    if curBeat == 1300 or curBeat == 1364 or curBeat == 1428 then 
        for i=0,3 do
            noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 1, 'elasticOut')
            noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 1, 'elasticOut')
        end
    end

    if curBeat == 1434 then
        if not middlescroll then
            noteTweenX('foxTween1', 4, 415 + Meow1, 1, 'cubeInOut');
            noteTweenX('foxTween2', 5, 415 + Meow2, 1, 'cubeInOut');
            noteTweenX('foxTween3', 6, 415 + Meow3, 1, 'cubeInOut');
            noteTweenX('foxTween4', 7, 415 + Meow4, 1, 'cubeInOut');
        end

        for i = 0, 3 do
            noteTweenAlpha("note"..i, i, 0, 1, "quadInOut")
        end
    end

    if curBeat == 1444 then 
        for i=0,3 do
            noteTweenX('resetX'..i, i, _G['defaultPlayerStrumX'..i], 1, 'elasticOut')
        end
    end

    if curBeat == 1556 then --и...
        setProperty('updateTime', false)
        setProperty('timeTxt.text', 'YOU CANNOT FUCK US')
    end

    if curBeat >= 1568 and curBeat < 1600 then
        for strums = 0,3 do
            setPropertyFromGroup('playerStrums',strums,'x',412 + (112 * strums) - (ofs * math.cos(strums)))
            noteTweenX('noteUniX1'..(strums+4),strums+4,412 + (112 * strums),stepCrochet*0.003,'cubeOut')
        end
    end

    if curBeat >= 1601 and curBeat < 1631 then
        for strums = 0,3 do
            setPropertyFromGroup('opponentStrums',strums,'x',412 + (112 * strums) - (ofs * math.cos(strums)))
            noteTweenX('noteUniX2'..strums,strums,412 + (112 * strums),stepCrochet*0.003,'cubeOut')
        end
    end

    if curBeat == 1600 then
        for strums = 0,3 do
            noteTweenX('moveSe'..strums,strums,getPropertyFromGroup('playerStrums',strums,'x'),0.2,'cubeOut')
            noteTweenX('movePl'..(strums+4),strums+4,getPropertyFromGroup('opponentStrums',strums,'x'),0.2,'cubeOut')
        end
    end

    
    if curBeat == 1631 then
        for strums = 0,3 do
            noteTweenAlpha('noteUniAlpha'..strums,strums,0,0.2,'cubeOut')
            noteTweenX('moveSiska'..(strums+4),strums+4,getPropertyFromGroup('playerStrums',strums,'x'),0.2,'cubeOut')
        end
    end


    if curBeat >= 1632 and curBeat < 1694 then
        for strums = 0,3 do
            setPropertyFromGroup('playerStrums',strums,'x',412 + (112 * strums) - (ofs * math.cos(strums)))
            noteTweenX('noteUniX2'..(strums+4),strums+4,412 + (112 * strums),stepCrochet*0.003,'cubeOut')
        end
    end

    if curBeat == 1694 then --Хуяк
        for strums = 0,3 do
            noteTweenAlpha('noteUniAlpha'..strums,strums,1,0.5)
            noteTweenAlpha('noteUniAlpha'..(strums+4),strums+4,0,0.3,'cubeIn')
        end
    end

    if curBeat == 1696 then --Хуяк
        for strums = 0,3 do
            noteTweenX('trabs'..strums,strums,getPropertyFromGroup('opponentStrums',strums,'x'),0.2,'cubeOut')
            noteTweenY('resetY'..strums, strums, _G['defaultOpponentStrumY'..strums], 0.2, 'cubeOut')
        end
    end

    if curBeat == 1720 then --Хуяк
        for strums = 0,3 do
            setPropertyFromGroup('playerStrums',strums,'x',screenWidth/2+(112*strums) - 230)
            setPropertyFromGroup('playerStrums',strums,'y',screenHeight/2 - 50)
        end

        if downscroll then
            startTween('down', 'strumLineNotes.members[5]', {direction = -90}, 0.3, {ease = 'elasticOut'})
            startTween('left', 'strumLineNotes.members[4]', {direction = 0}, 0.3, {ease = 'elasticOut'})
            startTween('up', 'strumLineNotes.members[6]', {direction = 90}, 0.3, {ease = 'elasticOut'})
            startTween('right', 'strumLineNotes.members[7]', {direction = 180}, 0.3, {ease = 'elasticOut'})
        else
            startTween('down', 'strumLineNotes.members[5]', {direction = 90}, 0.3, {ease = 'elasticOut'})
            startTween('left', 'strumLineNotes.members[4]', {direction = 180}, 0.3, {ease = 'elasticOut'})
            startTween('up', 'strumLineNotes.members[6]', {direction = -90}, 0.3, {ease = 'elasticOut'})
            startTween('right', 'strumLineNotes.members[7]', {direction = 0}, 0.3, {ease = 'elasticOut'})
        end
    end
end

function onSectionHit()
    if curSection == 384 then
        makeLuaSprite('StrumMoviment',nil,strumMovimentForce)
        doTweenX('StrumMovimentX','StrumMoviment',1,5,'linear')
        for strumNotes = 0,3 do
            setPropertyFromGroup('opponentStrums',strumNotes,'x',getPropertyFromGroup('playerStrums',strumNotes,'x'))
            noteTweenAlpha('noteUniAlpha'..strumNotes,strumNotes,0.6,5,'linear')
            if strumNotes < 2 then
                noteTweenX('noteUniX'..strumNotes,strumNotes,92 + (112*strumNotes),10,'linear')
            else
                noteTweenX('noteUniX'..strumNotes,strumNotes,732 + (112*strumNotes),10,'linear')
            end
        end
    elseif curSection == 432 then
        for strums = 0,3 do
            noteTweenAlpha('noteUniAlpha'..strums,strums,0,0.5,'linear')
        end
    elseif curSection == 433 then
        for strums = 0,3 do
            noteTweenAlpha('noteUniAlpha'..(strums+4),strums+4,1,0.5,'linear')
        end
    elseif curSection == 435 then
        for strums = 0,3 do
            noteTweenAlpha('noteUniAlpha'..(strums+4),strums+4,0,3,'linear')
        end
    end
end

function scrollChange(ease)
    for i = 0, 7 do
        noteTweenY('down'..i, i, (getPropertyFromClass('backend.ClientPrefs', 'data.downScroll') and 50 or 570), 0.5, ease)
    end

    downscrollMoment = not downscrollMoment
    setPropertyFromClass('backend.ClientPrefs', 'data.downScroll', downscrollMoment);

    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes',i,'downScroll', downscrollMoment)
    end
end

function InitscrollChange()
    for i = 0, 7 do
        noteTweenY('down'..i, i, ((initScroll) and 570 or 50), 1, "quadOut")
    end

    setPropertyFromClass('backend.ClientPrefs', 'data.downScroll', initScroll);

    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes',i,'downScroll', initScroll)
    end
end

function InitscrollChangeFinal()
    for i = 0, 7 do
        noteTweenY('down'..i, i, ((initScroll) and 570 or 50), 0.5, "elasticOut")
    end

    setPropertyFromClass('backend.ClientPrefs', 'data.downScroll', initScroll);

    for i = 0, 7 do
        setPropertyFromGroup('strumLineNotes',i,'downScroll', initScroll)
    end
end

function noteSquish(note, axis, mult, time)
    if axis == 'x' then
        setPropertyFromGroup('strumLineNotes', note, 'scale.x', defaultScaleX + mult)
        doTweenX('noteSquish'..axis..note, 'strumLineNotes.members['..note..'].scale', defaultScaleX, time, 'quadOut')
    else
        setPropertyFromGroup('strumLineNotes', note, 'scale.y', defaultScaleY + mult)
        doTweenY('noteSquish'..axis..note, 'strumLineNotes.members['..note..'].scale', defaultScaleY, time, 'quadOut')
    end
end

function scaleHitNote(noteData) --я ненавижу свою жизнь
    cancelTween('noteSquishx'..noteData)
    cancelTween('noteSquishy'..noteData)

    setPropertyFromGroup('strumLineNotes', noteData, 'scale.x', defaultScaleX - 10)
    doTweenX('noteSquishx'..noteData, 'strumLineNotes.members['..noteData..'].scale', defaultScaleX, 0.5, 'elasticOut')

    setPropertyFromGroup('strumLineNotes', noteData, 'scale.y', defaultScaleY - 10)
    doTweenY('noteSquishy'..noteData, 'strumLineNotes.members['..noteData..'].scale', defaultScaleY, 0.5, 'elasticOut')
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'direct' then
        directionMovie()
    end

    if tag == 'direct3' then
        directionMovie3()
    end

    if tag == 'strumMovimentX' then
        removeLuaSprite('StrumMovimentX',true)
    end
end

function directionMovie()
    if not noAngle then
        if shit then
            for i = 0,7 do
                startTween('noteDirectST'..i, 'strumLineNotes.members['..i..']', {direction = 110}, 3)
            end
        else
            for i = 0,7 do
                startTween('noteDirect'..i, 'strumLineNotes.members['..i..']', {direction = 70}, 3)
            end
        end
    
        shit = not shit
    end
end

function directionMovie3()
    if not noAngle then
        if shit then
            for i = 0,7 do
                startTween('noteDirectST3'..i, 'strumLineNotes.members['..i..']', {direction = 110}, 1)
            end
        else
            for i = 0,7 do
                startTween('noteDirect3'..i, 'strumLineNotes.members['..i..']', {direction = 70}, 1)
            end
        end
    
        shit = not shit
    end
end

function funni(intense) --да да я спиздил хахахаха СНОВА
    --- иди нахуй
    for i = 0,3 do
        setPropertyFromGroup('opponentStrums', i, 'x', 
        getPropertyFromGroup("opponentStrums", i, "x") + getRandomFloat(-intense, intense))

        setPropertyFromGroup('opponentStrums', i, 'y', 
        getPropertyFromGroup("opponentStrums", i, "y") + getRandomFloat(-intense, intense))

        setPropertyFromGroup('playerStrums', i, 'x', 
        getPropertyFromGroup("playerStrums", i, "x") + getRandomFloat(-intense, intense))

        setPropertyFromGroup('playerStrums', i, 'y', 
        getPropertyFromGroup("playerStrums", i, "y") + getRandomFloat(-intense, intense))

        noteTweenX("blyaDad"..i, i, _G["defaultOpponentStrumX"..i], 0.05, "quadOut")
        noteTweenY("pizdecDad"..i, i, _G["defaultOpponentStrumY"..i], 0.05, "quadOut")
        noteTweenX("blyaBF"..i, i + 4, _G["defaultPlayerStrumX"..i], 0.05, "quadOut")
        noteTweenY("pizdecBF"..i, i + 4, _G["defaultPlayerStrumY"..i], 0.05, "quadOut")
    end
end

function onEvent(n)
    if n == 'Direct bacc' then
        cancelTimer('direct')
        noAngle = true
		for i = 0,7 do
            callMethod('noteDirectST'..i..'.cancel')
            callMethod('noteDirect'..i..'.cancel')
            
            startTween('noteDirectBack'..i, 'strumLineNotes.members['..i..']', {direction = 90}, 0.3, {ease = 'elasticOut'})
        end
    end

    if n == 'initScro' then
        InitscrollChange()
    end

    if n == 'Direct bacc 2' then
        cancelTimer('direct3')
        noAngle = true
		for i = 0,7 do
            callMethod('noteDirectST3'..i..'.cancel')
            callMethod('noteDirect3'..i..'.cancel')
            
            startTween('noteDirectBack'..i, 'strumLineNotes.members['..i..']', {direction = 90}, 0.3, {ease = 'elasticOut'})
		end
    end
end

function onGameOver()
    setPropertyFromClass('backend.ClientPrefs', 'data.downScroll', initScroll);
end

function onUpdatePost(elapsed)
    for i=0, getProperty('notes.length')-1 do
        if getPropertyFromGroup('notes', i, 'isSustainNote') == true then
            if initScroll then
                setPropertyFromGroup('notes', i, 'flipY', getPropertyFromGroup("strumLineNotes", 0, 'downScroll'))
            else
                setPropertyFromGroup('notes', i, 'flipY', getPropertyFromGroup("strumLineNotes", 0, 'downScroll'))
            end
        end
    end

    if curBeat >= 1104 and curBeat <= 1131 then --КРУТИЛКА ХУИЛКА
        for i = 0, 7, 1 do
            setPropertyFromGroup('strumLineNotes', i, 'y', sinY + math.sin(getSongPosition() * 0.002 * 0.7  + i*0.8) * 50)
            setPropertyFromGroup('strumLineNotes', i, 'x', 600 + math.cos(getSongPosition() * 0.003 * 0.7 + i*0.8) * 200)
        end
    end

    if curBeat >= 1568 and curBeat < 1694 then
        if not inGameOver then
            for i=0,getProperty('notes.length') do
                if getPropertyFromGroup('notes',i,'isSustainNote') == true then
                    strum = getPropertyFromGroup('notes',i,'strumTime')
                    woom = (strum-getSongPosition())
                    if wiggleamp > 0 then
                    woom = (strum-getSongPosition())/wigglefreq
                    end
                    setPropertyFromGroup('notes',i,'angle',wiggleamp *math.sin(woom))
                end
            end
        end
    end
end