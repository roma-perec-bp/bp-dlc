function onCreate()
    setProperty('timeBar.visible', false)
    setProperty('timeTxt.visible', false)
end

function onStepHit()
    if curStep == 736 then
        playAnim('dad', 'singDOWN-alt', true)
        triggerEvent('Play Animation', 'dad', 'singDOWN-alt')
    end
end