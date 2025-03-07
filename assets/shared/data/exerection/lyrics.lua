local balls = false

function onCreate()
    luaDebugMode = true

    makeLuaText("lyrics", nil, 600, 500, 500);
    setTextSize('lyrics', 48)
    setTextFont("lyrics", 'HouseofTerrorRus.ttf')
    setObjectCamera("lyrics", "camHUD")
    addLuaText("lyrics");
    setProperty('lyrics.alpha', 0)
    screenCenter('lyrics', 'x')
end

function onBeatHit()
    if curBeat == 480 or curBeat == 508 or curBeat == 516 or curBeat == 544 or curBeat == 560 or curBeat == 576 or curBeat == 592 or curBeat == 604 or curBeat == 612 or curBeat == 620 or curBeat == 628 or curBeat == 636 or curBeat == 644 or curBeat == 652 or curBeat == 660 or curBeat == 666 then
        doTweenAlpha('byeLyrics', 'lyrics', 0, 0.5)
    end

    if curBeat == 521 or curBeat == 523 or curBeat == 525 or curBeat == 527 then
        setProperty('lyrics.alpha', 0)
    elseif curBeat == 520 or curBeat == 522 or curBeat == 524 or curBeat == 526 or curBeat == 528 then
        setProperty('lyrics.alpha', 1)
    end
    -- лирики
    if curBeat == 472 then
        setTextString("lyrics", "Вот и мы подошли к концу")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 488 then
        setTextString("lyrics", "Неужели умер я...?")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 500 then
        setTextString("lyrics", "О")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 502 then
        setTextString("lyrics", "О НЕТ!")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 504 then
        setTextString("lyrics", "Я всех наебал")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 512 then
        setTextString("lyrics", "И мой хуй ты пососал")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 520 then
        setTextString("lyrics", "СДОХНИ")
        setTextSize('lyrics', 64)
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 532 then
        setTextString("lyrics", "HWAW")
        setTextSize('lyrics', 64)
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 536 then
        setTextString("lyrics", "Вот и час настал")
        setTextSize('lyrics', 48)
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 540 then
        setTextString("lyrics", "И я тебя наебал")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 552 then
        setTextString("lyrics", "Твоя крыша вся в огне")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 556 then
        setTextString("lyrics", "Выжжена и вся в хуйне")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 568 then
        setTextString("lyrics", "Здесь лишь я проиду")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 572 then
        setTextString("lyrics", "И тебя я выебу")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 584 then
        setTextString("lyrics", "Хахахаха ты умрешь")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 588 then
        setTextString("lyrics", "И в аду ты выгоришь")
        setProperty('lyrics.alpha', 1)
    end
    --
    if curBeat == 600 then
        setTextString("lyrics", "Вот и час настал")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 608 then
        setTextString("lyrics", "И я тебя наебал")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 616 then
        setTextString("lyrics", "Твоя крыша вся в огне")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 624 then
        setTextString("lyrics", "Выжжена и вся в хуйне")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 632 then
        setTextString("lyrics", "Здесь лишь я проиду")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 640 then
        setTextString("lyrics", "И тебя я выебу")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 648 then
        setTextString("lyrics", "Хахахаха ты хорош")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 656 then
        setTextString("lyrics", "Может все же пройдешь")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat == 663 then
        setTextString("lyrics", "НЕТ")
        setProperty('lyrics.alpha', 1)
    end
    if curBeat >= 680 and curBeat < 744 then
        setProperty('lyrics.alpha', 1)
        setTextSize('lyrics', 100)
        setTextString("lyrics", "DON'T MISS")
        screenCenter('lyrics', 'xy')
    
        if balls then
            setProperty('lyrics.visible', false)
        else
            setProperty('lyrics.visible', true)
        end

        balls = not balls
    end
    if curBeat == 744 then
        removeLuaText('lyrics')
    end
end