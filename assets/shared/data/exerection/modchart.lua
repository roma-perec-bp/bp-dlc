local defaultScaleX
local defaultScaleY

local y = 0
local x = 0

local balls

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

  	if curBeat >= 80 and curBeat <= 112 or curBeat >= 408 and curBeat <= 471 then --МЫ МЫ БРУТАЛ ЭКС ПАРТ
		for i = 0, 7 do
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 10 * math.sin((currentBeat + i * 0.25) * math.pi))
			setPropertyFromGroup('strumLineNotes', i, 'y', defaultNotePos[i + 1][2] + 10 * math.cos((currentBeat + i * 0.25) * math.pi))
		end
	end

    if curBeat >= 216 and curBeat < 280 then --ТЫ НЕ ЕБЕЩБ НАС БРУТАЛ ЕБЕЩБ НАС
		for i = 0,7 do
			setPropertyFromGroup('strumLineNotes', i, 'x', defaultNotePos[i + 1][1] + 25 *math.sin((currentBeatAlt + i*0.25) * math.pi))
		end
	end

    if curBeat >= 112 and curBeat <= 143 or curBeat >= 152 and curBeat <= 216 or curBeat >= 280 and curBeat < 408 then
        if middlescroll then
            for i = 0, 3 do
                local noteX = 120 * i
                local offsetX = 320
                local thingy = 1
                if curBeat % 2 == 0 then
                  thingy = -1
                end
                setPropertyFromGroup("strumLineNotes", i + 4, "y", defaultOpponentStrumY0 + (math.sin((getSongPosition() - getPropertyFromClass('backend.ClientPrefs', 'data.noteOffset')) / crochet + (noteX - 120) * 2) * staticArrowWave + staticArrowWave * 0.5))
    
                setPropertyFromGroup("strumLineNotes", i + 4, "x", getPropertyFromGroup('strumLineNotes', 0, 'x')+noteX+offsetX+(thingy*staticArrowWave)*0.7)
            end
        else
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
    
                setPropertyFromGroup("strumLineNotes", i, "x",defaultOpponentStrumX0 + noteX + offsetX + (thingy * staticArrowWave) * 0.7)

            end
        end

        staticArrowWave = lerp(staticArrowWave,0,elapsed*8)
    end

    if curBeat >= 536 and curBeat < 662 then
            for i = 0, 3 do
                local noteX = 120 * i
                local offsetX = 320
                local thingy = 1
                if curBeat % 2 == 0 then
                  thingy = -1
                end
                setPropertyFromGroup("strumLineNotes", i+ 4, "y", defaultOpponentStrumY0 + (math.sin((getSongPosition() - getPropertyFromClass('backend.ClientPrefs', 'data.noteOffset')) / crochet + (noteX - 120) * 2) * staticArrowWave + staticArrowWave * 0.5))
    
                setPropertyFromGroup("strumLineNotes", i + 4, "x", getPropertyFromGroup('strumLineNotes', 0, 'x')+noteX+offsetX+(thingy*staticArrowWave)*0.7)
            end

        staticArrowWave = lerp(staticArrowWave,0,elapsed*8)
    end
end

function onStepHit()
    if curStep == 576 then
        for i=0,3 do
            setPropertyFromGroup('strumLineNotes', i, 'y',  _G['defaultOpponentStrumY'..i])
            setPropertyFromGroup('strumLineNotes', i, 'x',  _G['defaultOpponentStrumX'..i])

            setPropertyFromGroup('strumLineNotes', i+4, 'y',  _G['defaultPlayerStrumY'..i])
            setPropertyFromGroup('strumLineNotes', i+4, 'x',  _G['defaultPlayerStrumX'..i])
        end

        setPropertyFromGroup('strumLineNotes', 1, 'y',  _G['defaultOpponentStrumY1'] + 60)
        setPropertyFromGroup('strumLineNotes', 2, 'y',  _G['defaultOpponentStrumY2'] + 60)

        noteTweenY('danc', 1, _G['defaultOpponentStrumY1'], 0.1, 'quadOut')
        noteTweenY('dance2', 2, _G['defaultOpponentStrumY2'], 0.1, 'quadOut')

        setPropertyFromGroup('strumLineNotes', 5, 'y',  _G['defaultPlayerStrumY1'] + 60)
        setPropertyFromGroup('strumLineNotes', 6, 'y',  _G['defaultPlayerStrumY2'] + 60)

        noteTweenY('danc1', 5, _G['defaultPlayerStrumY1'], 0.1, 'quadOut')
        noteTweenY('dance12', 6,_G['defaultPlayerStrumY2'], 0.1, 'quadOut')
    end

    if curStep == 580 then
        setPropertyFromGroup('strumLineNotes', 0, 'x',  _G['defaultOpponentStrumX0'] - 60)
        setPropertyFromGroup('strumLineNotes', 3, 'x',  _G['defaultOpponentStrumX3'] + 60)

        noteTweenX('danc', 0, _G['defaultOpponentStrumX0'], 0.1, 'quadOut')
        noteTweenX('dance2', 3, _G['defaultOpponentStrumX3'], 0.1, 'quadOut')

        setPropertyFromGroup('strumLineNotes', 4, 'x',  _G['defaultPlayerStrumX0'] - 60)
        setPropertyFromGroup('strumLineNotes', 7, 'x',  _G['defaultPlayerStrumX3'] + 60)

        noteTweenX('danc1', 4, _G['defaultPlayerStrumX0'], 0.1, 'quadOut')
        noteTweenX('dance12', 7, _G['defaultPlayerStrumX3'], 0.1, 'quadOut')
    end

    if curStep == 584 then
        setPropertyFromGroup('strumLineNotes', 0, 'y', _G['defaultOpponentStrumY0'] - 35)
        setPropertyFromGroup('strumLineNotes', 4, 'y', _G['defaultPlayerStrumY0'] - 35)
    end

    if curStep == 586 then
        setPropertyFromGroup('strumLineNotes', 0, 'y', _G['defaultOpponentStrumY0'])
        setPropertyFromGroup('strumLineNotes', 4, 'y', _G['defaultPlayerStrumY0'])

        setPropertyFromGroup('strumLineNotes', 1, 'y', _G['defaultOpponentStrumY1'] - 35)
        setPropertyFromGroup('strumLineNotes', 5, 'y', _G['defaultPlayerStrumY1'] - 35)
    end

    if curStep == 588 then
        setPropertyFromGroup('strumLineNotes', 1, 'y', _G['defaultOpponentStrumY1'])
        setPropertyFromGroup('strumLineNotes', 5, 'y', _G['defaultPlayerStrumY1'])

        setPropertyFromGroup('strumLineNotes', 2, 'y', _G['defaultOpponentStrumY2'] - 35)
        setPropertyFromGroup('strumLineNotes', 6, 'y', _G['defaultPlayerStrumY2'] - 35)
    end

    if curStep == 590 then
        setPropertyFromGroup('strumLineNotes', 2, 'y', _G['defaultOpponentStrumY2'])
        setPropertyFromGroup('strumLineNotes', 6, 'y', _G['defaultPlayerStrumY2'])

        setPropertyFromGroup('strumLineNotes', 3, 'y', _G['defaultOpponentStrumY3'] - 35)
        setPropertyFromGroup('strumLineNotes', 7, 'y', _G['defaultPlayerStrumY3'] - 35)
    end

    if curStep == 592 then
        for i = 0, 7 do
            setPropertyFromGroup('strumLineNotes', i, 'angle', -360)
            noteTweenAngle("note"..i, i, 0, 1, "expoInOut")
        end

        setPropertyFromGroup('strumLineNotes', 3, 'y', _G['defaultOpponentStrumY3'])
        setPropertyFromGroup('strumLineNotes', 7, 'y', _G['defaultPlayerStrumY3'])

        setPropertyFromGroup('strumLineNotes', 1, 'y',  _G['defaultOpponentStrumY1'] + 60)
        setPropertyFromGroup('strumLineNotes', 2, 'y',  _G['defaultOpponentStrumY2'] + 60)

        noteTweenY('danc', 1, _G['defaultOpponentStrumY1'], 0.1, 'quadOut')
        noteTweenY('dance2', 2, _G['defaultOpponentStrumY2'], 0.1, 'quadOut')

        setPropertyFromGroup('strumLineNotes', 5, 'y',  _G['defaultPlayerStrumY1'] + 60)
        setPropertyFromGroup('strumLineNotes', 6, 'y',  _G['defaultPlayerStrumY2'] + 60)

        noteTweenY('danc1', 5, _G['defaultPlayerStrumY1'], 0.1, 'quadOut')
        noteTweenY('dance12', 6,_G['defaultPlayerStrumY2'], 0.1, 'quadOut')
    end

    if curStep == 596 then
        setPropertyFromGroup('strumLineNotes', 0, 'x',  _G['defaultOpponentStrumX0'] - 60)
        setPropertyFromGroup('strumLineNotes', 3, 'x',  _G['defaultOpponentStrumX3'] + 60)

        noteTweenX('danc', 0, _G['defaultOpponentStrumX0'], 0.1, 'quadOut')
        noteTweenX('dance2', 3, _G['defaultOpponentStrumX3'], 0.1, 'quadOut')

        setPropertyFromGroup('strumLineNotes', 4, 'x',  _G['defaultPlayerStrumX0'] - 60)
        setPropertyFromGroup('strumLineNotes', 7, 'x',  _G['defaultPlayerStrumX3'] + 60)

        noteTweenX('danc1', 4, _G['defaultPlayerStrumX0'], 0.1, 'quadOut')
        noteTweenX('dance12', 7, _G['defaultPlayerStrumX3'], 0.1, 'quadOut')
    end

    if curStep == 600 then
        setPropertyFromGroup('strumLineNotes', 0, 'x',  _G['defaultOpponentStrumX0'] - 60)
        setPropertyFromGroup('strumLineNotes', 3, 'x',  _G['defaultOpponentStrumX3'] + 60)

        noteTweenX('danc', 0, _G['defaultOpponentStrumX0'], 0.1, 'quadOut')
        noteTweenX('dance2', 3, _G['defaultOpponentStrumX3'], 0.1, 'quadOut')

        setPropertyFromGroup('strumLineNotes', 4, 'x',  _G['defaultPlayerStrumX0'] - 60)
        setPropertyFromGroup('strumLineNotes', 7, 'x',  _G['defaultPlayerStrumX3'] + 60)

        noteTweenX('danc1', 4, _G['defaultPlayerStrumX0'], 0.1, 'quadOut')
        noteTweenX('dance12', 7, _G['defaultPlayerStrumX3'], 0.1, 'quadOut')
    end

    if curStep == 604 then
        setPropertyFromGroup('strumLineNotes', 1, 'y',  _G['defaultOpponentStrumY1'] + 60)
        setPropertyFromGroup('strumLineNotes', 2, 'y',  _G['defaultOpponentStrumY2'] + 60)

        noteTweenY('danc', 1, _G['defaultOpponentStrumY1'], 0.1, 'quadOut')
        noteTweenY('dance2', 2, _G['defaultOpponentStrumY2'], 0.1, 'quadOut')

        setPropertyFromGroup('strumLineNotes', 5, 'y',  _G['defaultPlayerStrumY1'] + 60)
        setPropertyFromGroup('strumLineNotes', 6, 'y',  _G['defaultPlayerStrumY2'] + 60)

        noteTweenY('danc1', 5, _G['defaultPlayerStrumY1'], 0.1, 'quadOut')
        noteTweenY('dance12', 6,_G['defaultPlayerStrumY2'], 0.1, 'quadOut')
    end
end

function onBeatHit()
    if curBeat >= 112 and curBeat <= 143 then
        staticArrowWave = 16
    end

    if curBeat == 216 or curBeat == 472 or curBeat == 668 then
        for i = 0, 3 do
            noteTweenY('resetY'..i, i, _G['defaultOpponentStrumY'..i], 0.5, 'quadInOut')
            noteTweenY('resetY'..i + 4, i + 4, _G['defaultPlayerStrumY'..i], 0.5, 'quadInOut')
    
            noteTweenX('resetX'..i, i, _G['defaultOpponentStrumX'..i], 0.5, 'quadInOut')
            noteTweenX('resetX'..i + 4, i + 4, _G['defaultPlayerStrumX'..i], 0.5, 'quadInOut')
        end
    end

    if curBeat >= 152 and curBeat <= 216 then
        staticArrowWave = 25
    end

    if curBeat >= 536 and curBeat <= 664 then
        staticArrowWave = 35

        if balls then
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', 25)
                noteTweenAngle("angleLeft"..i, i, 0, 0.2, "quadOut")
            end
        else
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', -25)
                noteTweenAngle("angleRight"..i, i, 0, 0.2, "quadOut")
            end
        end
    end

    if curBeat >= 280 and curBeat < 408 then
        staticArrowWave = 25

        if balls then
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', 15)
                noteTweenAngle("angleLeft"..i, i, 0, 0.2, "quadOut")
            end
        else
            for i = 0, 7 do
                setPropertyFromGroup('strumLineNotes', i, 'angle', -15)
                noteTweenAngle("angleRight"..i, i, 0, 0.2, "quadOut")
            end
        end
    end

    if curBeat == 528 then --HARD STYLE TIME
        for i = 0, 3 do
            noteTweenAlpha("note"..i, i, 0, 1, "linear")
        end
    end

    if curBeat == 532 then --HARD STYLE TIME
        if not middlescroll then
            noteTweenX('foxTween1', 4, 415 + Meow1, 1, 'backOut');
            noteTweenX('foxTween2', 5, 415 + Meow2, 1, 'backOut');
            noteTweenX('foxTween3', 6, 415 + Meow3, 1, 'backOut');
            noteTweenX('foxTween4', 7, 415 + Meow4, 1, 'backOut');
        end
    end

    if curBeat == 664 then --HARD STYLE TIME
        for i = 0, 7 do
            noteTweenAlpha("note"..i, i, 0, 0.0001, "linear")
        end
    end

    if curBeat == 680 then --HARD STYLE TIME
        for i = 0, 7 do
            noteTweenAlpha("note"..i, i, 1, 0.6, "linear")
        end
    end
end