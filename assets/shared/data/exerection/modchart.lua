local defaultScaleX
local defaultScaleY

local y = 0
local x = 0

local defaultNotePos = {};

local Meow1 = 0
local Meow2 = 112
local Meow3 = 112 * 2
local Meow4 = 112 * 3

function onSongStart()
	for i = 0,7 do 
		x = getPropertyFromGroup('strumLineNotes', i, 'x')

		y = getPropertyFromGroup('strumLineNotes', i, 'y')

        defaultScaleX = getPropertyFromGroup('strumLineNotes', i, 'scale.x')
        defaultScaleY = getPropertyFromGroup('strumLineNotes', i, 'scale.y')

		table.insert(defaultNotePos, {x,y})
	end
end

local staticArrowWave = 0
local function lerp(a,b,t) return a+(b-a)*t end
function onUpdate(elapsed)
	local songPos = getPropertyFromClass('backend.Conductor', 'songPosition');
  	local songPosSpeed = getPropertyFromClass('backend.Conductor', 'songPosition') / 500
	currentBeat = (songPos / 1750) * (bpm / 100)
	currentBeatAlt = (songPos / 1250) * (bpm / 100)

  	if curBeat >= 408 and curBeat <= 472 then --МЫ МЫ БРУТАЛ ЭКС ПАРТ
		for i = 0, 7 do
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 10 * math.sin((currentBeat + i * 0.25) * math.pi))
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + 10 * math.cos((currentBeat + i * 0.25) * math.pi))
		end
	end

    if curBeat >= 216 and curBeat < 280 or curBeat >= 472 and curBeat < 532 then --ТЫ НЕ ЕБЕЩБ НАС БРУТАЛ ЕБЕЩБ НАС
		for i = 0,7 do
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 25 *math.sin((currentBeatAlt + i*0.25) * math.pi))
		end
	end

    if curBeat >= 112 and curBeat <= 152 or curBeat >= 280 and curBeat < 408 then
        for i = 0, 7 do
            local noteX = 120 * i
            local offsetX = 140
            local thingy = 1
            if curBeat % 2 == 0 then
                thingy = -1
            end
            if i < 4 then
                offsetX = 0
            end
            setPropertyFromGroup("strumLineNotes", i, "y", defaultOpponentStrumY0 + (math.sin((getSongPosition() - getPropertyFromClass('backend.ClientPrefs', 'data.noteOffset')) / crochet + (noteX - 120) * 2) * staticArrowWave + staticArrowWave * 0.5))

            setPropertyFromGroup("strumLineNotes", i, "x", defaultOpponentStrumX0 + noteX + offsetX + (thingy * staticArrowWave) * 0.7)
        end
        staticArrowWave = lerp(staticArrowWave,0,elapsed*8)
    end
end

function onBeatHit()
    if curBeat >= 112 and curBeat <= 152 or curBeat >= 280 and curBeat < 408 then
        staticArrowWave = 40
    end

    if curBeat == 152 or curBeat == 408 or curBeat == 216 then
        noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'quadOut')
        noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'quadOut')

        noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 0.5, 'quadOut')
        noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 0.5, 'quadOut')
    end

    if curBeat >= 152 and curBeat <= 216 or curBeat >= 536 and curBeat < 664 then
        staticArrowWave = 40
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

        for i = 0,7 do 
            x = getPropertyFromGroup('strumLineNotes', i, 'x')
    
            y = getPropertyFromGroup('strumLineNotes', i, 'y')
    
            table.insert(defaultNotePos, {x,y})
        end
    end

    if curBeat == 479 then
        for i = 0, 7 do
			noteTweenAngle('note'..i, i, 360, 0.6, 'quadInOut')
		end
    end

    if curBeat == 664 then --HARD STYLE TIME
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
            noteTweenX('foxTween1', 4, 415 + Meow1, 4, 'quadOut');
            noteTweenX('foxTween2', 5, 415 + Meow2, 4, 'quadOut');
            noteTweenX('foxTween3', 6, 415 + Meow3, 4, 'quadOut');
            noteTweenX('foxTween4', 7, 415 + Meow4, 4, 'quadOut');
        end
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