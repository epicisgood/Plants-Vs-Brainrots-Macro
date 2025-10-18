nowUnix() {
    return DateDiff(A_NowUTC, "19700101000000", "Seconds")
}


LastShopTime := nowUnix()



RewardChecker() {
    global LastShopTime

    Rewardlist := []

    currentTime := nowUnix()


    if (currentTime - LastShopTime >= 300) {
        LastShopTime := currentTime
        Rewardlist.Push("Seeds")
        Rewardlist.Push("Gears")  
        ; Rewardlist.Push("HitList")      
        Rewardlist.Push("EquipBest")      
    }

    return Rewardlist
}

; Calls RewardChecker -> RewardChecked functions to see if we are able to run those things
RewardInterupt() {

    variable := RewardChecker()

    for (k, v in variable) {
        ToolTip("")
        ActivateRoblox()
        if (v = "Seeds") {
            BuySeeds()
        }
        if (v = "Gears") {
            BuyGears()
        }
        ; if (v = "HitList") {
        ;     HitList()
        ; }
        if (v = "EquipBest") {
            EquipBestBrainrot()
        }
    }
    
    if (variable.Length > 0) {
        Clickbutton("Garden")
        relativeMouseMove(0.5, 0.5)
        return 1
    }
}


