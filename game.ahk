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
    logDebug(Format("streak: {},  index: {}, codScore: {}, crashScore: {}", newState.streak, newState.streakIndex, newState.codScore, newState.crashScore))
    return newState
}

handleCrash(currentState) {
    nextCodScore := currentState.codScore
    nextCrashScore := currentState.crashScore + 1
    msg := generateKillFeed()
    sendNotification(msg, nextCodScore, nextCrashScore)
    return { streak: 0, streakIndex: 1, codScore: nextCodScore, crashScore: nextCrashScore }
}

handleClose(currentState){
    newStreak := currentState.streak + 1
    newStreakIndex := currentState.streakIndex
    nextStreak := pointStreaks[currentState.streakIndex]
    nextCodScore := currentState.codScore + 1
    nextCrashScore := currentState.crashScore
    if (newStreak >= nextStreak.requiredStreak) {
        streakName := pointStreaks[currentState.streakIndex].name
        msg := Format("COD called in a {}", streakName)
        sendNotification(msg, nextCodScore, nextCrashScore)

        newStreakIndex := currentState.streakIndex + 1
        if (newStreakIndex > 4) {
            logDebug("rolling streak index")
            newStreakIndex := 1
        }
    }
    return { streak: newStreak, streakIndex: newStreakIndex, codScore: nextCodScore, crashScore: nextCrashScore }
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