#Include %A_ScriptDir%\logger.ahk

pointStreaks := [
{requiredStreak: 3, name: "✈️ UAV"},
{requiredStreak: 4, name: "🛩️ Counter UAV"},
{requiredStreak: 12, name: "🛰️ Advanced UAV"},
{requiredStreak: 30, name: "☢️ Tactical Nuke"}
]

processState(currentState, didCrash) {
    newState := didCrash 
        ? handleCrash(currentState) 
        : handleClose(currentState)

    newState := checkWinCondition(newState)
    logDebug(Format("codStreak: {},  codIndex: {}, codScore: {}, crashStreak: {}, crashIndex: {}, crashScore: {}", newState.codStreak, newState.codStreakIndex, newState.codScore,  newState.crashStreak, newState.crashStreakIndex, newState.crashScore))
    return newState
}

handleCrash(currentState) {
    newCrashStreak := currentState.crashStreak + 1
    newCrashScore := currentState.crashScore + 1
    newCodScore := currentState.codScore
    msg := generateKillFeed()
    sendNotification(msg, newCodScore, newCrashScore)
    newCrashStreakIndex := checkStreakCondition("Crash", newCrashStreak, currentState.crashStreakIndex, newCodScore, newCrashScore)

    return { 
        codStreak: 0, 
        codStreakIndex: 1, 
        codScore: newCodScore, 
        crashStreak: newCrashStreak,
        crashStreakIndex: newCrashStreakIndex,
        crashScore: newCrashScore 
    }
}

handleClose(currentState){
    newCrashScore := currentState.crashScore
    newCodStreak := currentState.codStreak + 1
    newCodScore := currentState.codScore + 1
    newCodStreakIndex := checkStreakCondition("COD", newCodStreak, currentState.codStreakIndex, newCodScore, newCrashScore)
    
    return { 
        codStreak: newCodStreak, 
        codStreakIndex: newCodStreakIndex, 
        codScore: newCodScore, 
        crashStreak: 0,
        crashStreakIndex: 1, 
        crashScore: newCrashScore 
    }
}

;bleh
checkStreakCondition(player, currentStreak, currentStreakIndex, codScore, crashScore){
    nextStreak := pointStreaks[currentStreakIndex]
    if (currentStreak >= nextStreak.requiredStreak) {
        streakName := pointStreaks[currentStreakIndex].name
        msg := Format("{} called in a {}", player, streakName)
        ;bleh
        sendNotification(msg, codScore, crashScore)

        newStreakIndex := currentStreakIndex + 1
        if (newStreakIndex > 4) {
            logDebug("rolling streak index")
            newStreakIndex := 1
        }
        return newStreakIndex
    }else{
        return currentStreakIndex
    }
}

checkWinCondition(currentState){
    scoreLimit := 75
    if(currentState.codScore >= scoreLimit || currentState.crashScore >= scoreLimit){
        winner := currentState.codScore > currentState.crashScore ? "COD" : "CRASH"
        msg := Format("Game Over, {} won", winner)
        sendNotification(msg, currentState.codScore, currentState.crashScore)
        return {streak: 0, streakIndex: 1, codScore: 0, crashScore: 0}
    } else {
        return currentState
    }
}

generateKillFeed() {
    enemies := ["zamboni", "badcode", "sofakinggoated", "Jev"]
    msg := Format("{} 🔫 COD", enemies[Random(1,4)])
    return msg
}

sendNotification(msg, codScore, crashScore) { 
    logDebug(msg)
    TrayTip(Format("{} | cod: {} crash: {}", msg, codScore, crashScore))
}