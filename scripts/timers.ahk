nowUnix() {
    return DateDiff(A_NowUTC, "19700101000000", "Seconds")
}


LastShopTime := nowUnix()
LastInvasionTime := nowUnix()


RewardChecker() {
    global LastShopTime, LastInvasionTime

    Rewardlist := []

    currentTime := nowUnix()


    if (currentTime - LastShopTime >= 300) {
        LastShopTime := currentTime
        Rewardlist.Push("Seeds")
        Rewardlist.Push("Gears")  
        Rewardlist.Push("EquipBest")      
    }
    if (currentTime - LastInvasionTime >= 1860) {
        LastInvasionTime := currentTime
        Rewardlist.Push("invasion")      
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
        if (v = "invasion") {
            invasion()
        }
        if (v = "EquipBest") {
            EquipBestBrainrots()
        }
    }
    
    if (variable.Length > 0) {
        Clickbutton("Garden")
        relativeMouseMove(0.5, 0.5)
        return 1
    }
}


