#Include %A_ScriptDir%\logger.ahk

pointStreaks := [
{requiredStreak: 3, name: "✈️ UAV"},
{requiredStreak: 4, name: "🛩️ Counter UAV"},
{requiredStreak: 12, name: "🛰️ Advanced UAV"},
{requiredStreak: 30, name: "☢️ Tactical Nuke"}
]

processState(currentState, didCrash) {
    if (didCrash){
        generateKillFeed(currentState)
        newStreak := 0
        newStreakIndex := 1
    } else {
        newStreak := currentState.streak + 1
        newStreakIndex := currentState.streakIndex
        nextStreak := pointStreaks[currentState.streakIndex]
        if (newStreak >= nextStreak.requiredStreak) {
            callInStreak(pointStreaks[currentState.streakIndex].name)
            newStreakIndex := currentState.streakIndex + 1
            if (newStreakIndex > 4) {
                logInfo("rolling streak index")
                newStreakIndex := 1
            }
        }
    }
    newState := {streak: newStreak, streakIndex: newStreakIndex}
    logInfo(Format("streak:{1} streakIndex:{2}", newStreak, newStreakIndex))
    return newState
}

callInStreak(name){
    msg := Format("COD called in a {}", name)
    logInfo(msg)
    TrayTip(msg)
}

generateKillFeed(currentState) {
    enemies := ["zamboni", "badcode", "sofakinggoated", "Jev"]
    nextStreak := pointStreaks[currentState.streakIndex].requiredStreak
    baseMsg := Format("{} 🔫 COD", enemies[Random(1,4)])
    msg := currentState.streak + 1 >= nextStreak ? Format("(buzzkill) {}", baseMsg) : baseMsg
    logInfo(msg)
    TrayTip(msg)
}