-- игры кончились чмо

local turnvalue = 20
local x1 = 0
local x2 = 0

local sosal
local iconP1Y = 0
local iconP2Y = 0

function onCreatePost()
    makeLuaSprite('iconP1obj', nil)
    makeLuaSprite('iconP2obj', nil)
    iconP2Y = getProperty('iconP2.y')
    iconP1Y = getProperty('iconP1.y')
    makeLuaSprite('iconScale', nil)
end

function onUpdatePost(elapsed)
    if curBeat >= 96 and curBeat < 128 or curBeat >= 304 and curBeat < 336 or curBeat >= 612 and curBeat < 644 or curBeat >= 888 and curBeat < 918 or curBeat >= 1268 and curBeat < 1300 or curBeat >= 1332 and curBeat < 1364 or curBeat >= 1396 and curBeat < 1428 then
        x1 = screenWidth - getProperty('healthBar.x') - (getProperty('healthBar.width') * (getProperty('healthBar.percent') * 0.01)) + (150 * getProperty('iconP1obj.scale.x') - 150) / 2 - 26
        x2 = screenWidth - getProperty('healthBar.x') - (getProperty('healthBar.width') * (getProperty('healthBar.percent') * 0.01)) - (150 * getProperty('iconP2obj.scale.x')) / 2 - 26 * 2
        setProperty('iconP1.x', x1)
        setProperty('iconP2.x', x2)
        setProperty('iconP1.scale.x', getProperty('iconP1obj.scale.x'))
        setProperty('iconP2.scale.x', getProperty('iconP2obj.scale.x'))
        setProperty('iconP1.scale.y', getProperty('iconP1obj.scale.y'))
        setProperty('iconP2.scale.y', getProperty('iconP2obj.scale.y'))
        setProperty('iconP1.y', getProperty('healthBar.y') - 150 - (150 * getProperty('iconP1.scale.y') / -2))
        setProperty('iconP2.y', getProperty('healthBar.y') - 150 - (150 * getProperty('iconP2.scale.y') / -2))
    end

    if curBeat >= 920 and curBeat < 984 then
        setProperty('iconP1.scale.x', getProperty('iconScale.scale.x'))
        setProperty('iconP1.scale.y', getProperty('iconScale.scale.y'))
        setProperty('iconP2.scale.x', getProperty('iconScale.scale.x'))
        setProperty('iconP2.scale.y', getProperty('iconScale.scale.y'))
    end

    if curBeat >= 588 and curBeat < 596 then
        setProperty('iconP1.offset.x', getRandomFloat(-4, 4))
        setProperty('iconP1.offset.y', getRandomFloat(-4, 4))
        setProperty('iconP2.offset.x', getRandomFloat(-4, 4))
        setProperty('iconP2.offset.y', getRandomFloat(-4, 4))
    end

    if curBeat >= 1236 and curBeat < 1440 then -- это для пиздец момента 🤫🧏🏻‍♂️
        setProperty('iconP1.offset.x', getRandomFloat(-10, 10))
        setProperty('iconP1.offset.y', getRandomFloat(-10, 10))
    end
end

function onBeatHit()
    -- circle
    if curBeat >= 136 and curBeat < 208 or curBeat >= 216 and curBeat < 224 or curBeat >= 232 and curBeat < 240 or curBeat >= 248 and curBeat < 256 or curBeat >= 264 and curBeat < 272 or curBeat >= 460 and curBeat < 476 or curBeat >= 572 and curBeat < 588 or curBeat >= 596 and curBeat < 604 or curBeat >= 992 and curBeat < 1024 or curBeat >= 1300 and curBeat < 1332 then
        turnvalue = 20
        if curBeat % 4 == 0 then
            turnvalue = 120
        else 
            turnvalue = -20
        end

        setProperty('iconP2.angle',-turnvalue)
        setProperty('iconP1.angle',turnvalue)

        doTweenAngle('iconTween1','iconP1',0,crochet/1000,'circOut')
        doTweenAngle('iconTween2','iconP2',0,crochet/1000,'circOut')
    end
    -- bounce
    if curBeat >= 64 and curBeat < 96 or curBeat >= 476 and curBeat < 508 or curBeat >= 644 and curBeat < 676 or curBeat >= 1364 and curBeat < 1396 then
        if getProperty('curBeat') % 1 == 0 then
			setProperty('iconP1.angle',1 * -15)
			setProperty('iconP2.angle',1 * 15)
			doTweenAngle('playericon', 'iconP1', 0, 0.5, 'linear')
			doTweenAngle('opponenticon', 'iconP2', 0, 0.5, 'linear')
    	end

    	if getProperty('curBeat') % 2 == 0 then
    			setProperty('iconP1.angle',1 * 15)
    			setProperty('iconP2.angle',1 * -15)
    			doTweenAngle('playericon', 'iconP1', 0, 0.5, 'linear')
    			doTweenAngle('opponenticon', 'iconP2', 0, 0.5, 'linear')
        end
    end

    -- aboba
    if curBeat >= 692 and curBeat < 708 then
        if getProperty('curBeat') % 1 == 0 then
			setProperty('iconP2.angle',1 * 15)
			doTweenAngle('opponenticon', 'iconP2', 0, 0.5, 'linear')
    	end
    end

    -- abobaZ
    if curBeat >= 696 and curBeat < 708 then
        if getProperty('curBeat') % 1 == 0 then
			setProperty('iconP1.angle',1 * -15)
			doTweenAngle('playericon', 'iconP1', 0, 0.5, 'linear')
    	end
    end
--small big
    if curBeat >= 508 and curBeat < 540 or curBeat >= 856 and curBeat < 872 then
        if curBeat % 2 == 0 then
            scaleObject('iconP1', 0.8)
		    scaleObject('iconP2', 1.2)
        elseif curBeat % 2 == 1 then
            scaleObject('iconP1', 1.2)
            scaleObject('iconP2', 0.8)
        end
    end
-- up down
    if curBeat >= 556 and curBeat < 572 or curBeat >= 708 and curBeat < 740 or curBeat >= 840 and curBeat < 856 or curBeat >= 872 and curBeat < 888 then
        if sosal then
            cancelTween("bap")
            cancelTween("bap2")
            doTweenY("beep", "iconP1", iconP1Y + 25, 0.5, "elasticOut")
            doTweenY("beep2", "iconP2", iconP2Y - 25, 0.5, "elasticOut")
            sosal = false
        else
            cancelTween("beep")
            cancelTween("beep2")
            doTweenY("bap", "iconP1", iconP1Y - 25, 0.5, "elasticOut")
            doTweenY("bap2", "iconP2", iconP2Y + 25, 0.5, "elasticOut")
            sosal = true
        end
    end
    --bring back
    if curBeat == 572 or curBeat == 740 or curBeat == 856 or curBeat == 888 then
        doTweenY("beep", "iconP1", iconP1Y, 1, "quadOut")
        doTweenY("beepeee", "iconP2", iconP2Y, 1, "quadOut")
    end
    --dnb
    if curBeat >= 96 and curBeat < 128 or curBeat >= 304 and curBeat < 336 or curBeat >= 612 and curBeat < 644 or curBeat >= 888 and curBeat < 918 or curBeat >= 1268 and curBeat < 1300 or curBeat >= 1332 and curBeat < 1364 or curBeat >= 1396 and curBeat < 1428 then
        if curBeat % getProperty('gfSpeed') == 0 then
            if curBeat % (getProperty('gfSpeed') * 2) == 0 then
                scaleObject('iconP1obj', 1.1, 0.8)
                scaleObject('iconP2obj', 1.1, 1.3)
                setProperty('iconP1.angle', -15)
                setProperty('iconP2.angle', 15)
            else
                scaleObject('iconP1obj', 1.1, 1.3)
                scaleObject('iconP2obj', 1.1, 0.8)
                setProperty('iconP1.angle', 15)
                setProperty('iconP2.angle', -15)
            end
    end
        doTweenAngle('icon1tween', 'iconP1', 0, crochet / 1300 * getProperty('gfSpeed'), 'quadOut')
        doTweenAngle('icon2tween', 'iconP2', 0, crochet / 1300 * getProperty('gfSpeed') , 'quadOut')
        doTweenX('icon1objx', 'iconP1obj.scale', 1, crochet / 1300 * getProperty('gfSpeed'), 'quadOut')
        doTweenX('icon2objx', 'iconP2obj.scale', 1, crochet / 1300 * getProperty('gfSpeed'), 'quadOut')
        doTweenY('icon1objy', 'iconP1obj.scale', 1, crochet / 1300 * getProperty('gfSpeed'), 'quadOut')
        doTweenY('icon2objy', 'iconP2obj.scale', 1, crochet / 1300 * getProperty('gfSpeed'), 'quadOut')
    end

    if curBeat >= 920 and curBeat < 984 then
        if curBeat % 2 == 0 then
            setProperty('iconScale.scale.x', 2)
            setProperty('iconScale.scale.y', 0.5)
    
            setProperty('iconP1.angle', -20)
            setProperty('iconP2.angle', 20)
    
            doTweenX('scale1', 'iconScale.scale', 1, 3.5, 'elasticOut')
            doTweenY('scale2', 'iconScale.scale', 1, 3.5, 'elasticOut')
    
            doTweenAngle('p1Ang', 'iconP1', 0, 1, 'elasticOut')
            doTweenAngle('p2Ang', 'iconP2', 0, 1, 'elasticOut')
        else
            setProperty('iconScale.scale.x', 0.5)
            setProperty('iconScale.scale.y', 2)
    
            setProperty('iconP1.angle', 20)
            setProperty('iconP2.angle', -20)
    
            doTweenX('scale1', 'iconScale.scale', 1, 3.5, 'elasticOut')
            doTweenY('scale2', 'iconScale.scale', 1, 3.5, 'elasticOut')
    
            doTweenAngle('p1Ang', 'iconP1', 0, 1, 'elasticOut')
            doTweenAngle('p2Ang', 'iconP2', 0, 1, 'elasticOut')
        end
    end
    --ascend
    if curBeat >= 1568 and curBeat < 1694 then
        scaleObject('iconP1', 2, 2)
    end

    if curBeat >= 1632 and curBeat < 1664 then
        setProperty('iconP1.angle',360)
        doTweenAngle('iconTweenGOD','iconP1',0,crochet/1000,'circOut')
    end
end