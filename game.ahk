#Include %A_ScriptDir%\logger.ahk

pointStreaks := [
{requiredStreak: 3, name: "✈️ UAV"},
{requiredStreak: 4, name: "🛩️ Counter UAV"},
{requiredStreak: 12, name: "🛰️ Advanced UAV"},
{requiredStreak: 30, name: "☢️ Tactical Nuke"}
]

scoreboard := {
    codScore: 0,
    crashScore: 0
}

processState(currentState, didCrash) {
    if (didCrash){
        generateKillFeed(currentState)
        newStreak := 0
        newStreakIndex := 1
        scoreboard.crashScore := scoreboard.crashScore + 1
    } else {
        newStreak := currentState.streak + 1
        newStreakIndex := currentState.streakIndex
        nextStreak := pointStreaks[currentState.streakIndex]
        scoreboard.codScore := scoreboard.codScore + 1
        if (newStreak >= nextStreak.requiredStreak) {
            callInStreak(pointStreaks[currentState.streakIndex].name)
            newStreakIndex := currentState.streakIndex + 1
            if (newStreakIndex > 4) {
                logInfo("rolling streak index")
                newStreakIndex := 1
            }
        }
    }
    
    if(scoreboard.codScore >= 75 || scoreboard.crashScore >= 75){
        winner := scoreboard.codScore >= 75 ? "COD" : "CRASH"
        msg := Format("Game Over, {} won", winner)
        sendNotification(msg)
        newState := {streak: 0, streakIndex: 1}
        return newState
    }
    
    newState := {streak: newStreak, streakIndex: newStreakIndex}
    logInfo(Format("streak:{1} streakIndex:{2}", newStreak, newStreakIndex))
    return newState
}

callInStreak(name){
    msg := Format("COD called in a {}", name)
    TrayTip(msg)
}

generateKillFeed(currentState) {
    enemies := ["zamboni", "badcode", "sofakinggoated", "Jev"]
    nextStreak := pointStreaks[currentState.streakIndex].requiredStreak
    baseMsg := Format("{} 🔫 COD", enemies[Random(1,4)])
    msg := currentState.streak + 1 >= nextStreak ? Format("(buzzkill) {}", baseMsg) : baseMsg
    TrayTip(msg)
}

sendNotification(msg) {
    logInfo(msg)
    TrayTip(Format("{} | cod:{} crash:{}", msg, scoreboard.codScore, scorboard.crashScore))
}
