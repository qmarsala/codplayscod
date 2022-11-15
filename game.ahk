#Include %A_ScriptDir%\logger.ahk

pointStreaks := [
{requiredStreak: 3, name: "✈️ UAV"},
{requiredStreak: 4, name: "🛩️ Counter UAV"},
{requiredStreak: 12, name: "🛰️ Advanced UAV"},
{requiredStreak: 30, name: "☢️ Tactical Nuke"}
]

processState(currentState, didCrash) {
    if (didCrash){
        newStreak := 0
        newStreakIndex := 1
        nextCrashScore := currentState.crashScore + 1
        msg := generateKillFeed()
        sendNotification(msg, currentState.codScore, nextCrashScore)
    } else {
        newStreak := currentState.streak + 1
        newStreakIndex := currentState.streakIndex
        nextStreak := pointStreaks[currentState.streakIndex]
        nextCodScore := currentState.codScore + 1
        if (newStreak >= nextStreak.requiredStreak) {
            streakName := pointStreaks[currentState.streakIndex].name
            msg := Format("COD called in a {}", streakName)
            sendNotification(msg, nextCodScore, currentState.crashScore)

            newStreakIndex := currentState.streakIndex + 1
            if (newStreakIndex > 4) {
                logDebug("rolling streak index")
                newStreakIndex := 1
            }
        }
    }
    

    if(nextCodScore >= 75 || nextCrashScore >= 75){
        winner := nextCodScore >= 75 ? "COD" : "CRASH"
        msg := Format("Game Over, {} won | cod: {} crash: {}", winner, nextCodScore, nextCrashScore)
        sendNotification(msg)
        newState := {streak: 0, streakIndex: 1, codScore: 0, crashScore: 0}
    } else {
        newState := {streak: newStreak, streakIndex: newStreakIndex, codScore: nextCodScore, crashScore: nextCrashScore}
    }
    logDebug(Format("streak:{} streakIndex:{}", newStreak, newStreakIndex))
    return newState
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