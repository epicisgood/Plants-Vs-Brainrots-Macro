﻿#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn VarUnset, Off
SetWorkingDir A_ScriptDir . "\.."
KeyDelay := 40

Setkeydelay KeyDelay

GetRobloxClientPos()
pToken := Gdip_Startup()
bitmaps := Map()
bitmaps.CaseSense := 0
currentWalk := {pid:"", name:""} ; stores "pid" (script process ID) and "name" (pattern/movement name)
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"

WKey:="sc011" ; w
AKey:="sc01e" ; a
SKey:="sc01f" ; s
Dkey:="sc020" ; d


RotLeft := "vkBC" ; ,
RotRight := "vkBE" ; .
RotUp := "sc149" ; PgUp
RotDown := "sc151" ; PgDn
ZoomIn := "sc017" ; i
ZoomOut := "sc018" ; o
Ekey := "sc012" ; e
Rkey := "sc013" ; r
Lkey := "sc026" ; l
EscKey := "sc001" ; Esc
EnterKey := "sc01c" ; Enter
SpaceKey := "sc039" ; Space
SlashKey := "vk6F" ; /
SC_LShift:="sc02a" ; LShift



#Include "%A_ScriptDir%"
#include ..\lib\

#Include FormData.ahk
#Include Gdip_All.ahk
#include Gdip_ImageSearch.ahk
#include json.ahk
#Include roblox.ahk
#Include ComVar.ahk
#Include Promise.ahk
#Include WebView2.ahk
#Include WebViewToo.ahk

#Include ..\images\
#include bitmaps.ahk
#include ..\scripts\

#Include gui.ahk
#Include webhook.ahk
#Include timers.ahk




;@Ahk2Exe-AddResource Gui\index.html, Gui\index.html
;@Ahk2Exe-AddResource Gui\script.js, Gui\script.js
;@Ahk2Exe-AddResource Gui\style.css, Gui\style.css
;@Ahk2Exe-AddResource ..\Lib\32bit\WebView2Loader.dll, 32bit\WebView2Loader.dll
;@Ahk2Exe-AddResource ..\Lib\64bit\WebView2Loader.dll, 64bit\WebView2Loader.dll



HyperSleep(ms) {
    static freq := (DllCall("QueryPerformanceFrequency", "Int64*", &f := 0), f)
    DllCall("QueryPerformanceCounter", "Int64*", &begin := 0)
    current := 0, finish := begin + ms * freq / 1000
    while (current < finish) {
        if ((finish - current) > 30000) {
            DllCall("Winmm.dll\timeBeginPeriod", "UInt", 1)
            DllCall("Sleep", "UInt", 1)
            DllCall("Winmm.dll\timeEndPeriod", "UInt", 1)
        }
        DllCall("QueryPerformanceCounter", "Int64*", &current)
    }
}

Walk(studs, MoveKey1, MoveKey2:=0) {
	Send "{" MoveKey1  " down}" (MoveKey2 ? "{" MoveKey2  " down}" : "")
	Sleep studs
	Send "{" MoveKey1  " up}" (MoveKey2 ? "{" MoveKey2  " up}" : "")
}

CheckDisconnnect(){
    static VipLink := IniRead(settingsFile, "Settings", "VipLink")
    hwnd := GetRobloxHWND()
    GetRobloxClientPos()
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["disconnected"], , , , , , 2) = 1 || GetRobloxHWND() == 0)  {
        PlayerStatus("Starting Plants Vs Brainrots", "0x00a838", ,false, ,false)    
        Gdip_DisposeImage(pBMScreen)
        CloseRoblox()
        PlaceID := 127742093697776

        linkCode := ""
        shareCode := ""

        if RegExMatch(VipLink, "privateServerLinkCode=(\d+)", &match)
            linkCode := match[1]
        else if RegExMatch(VipLink, "code=([a-f0-9]+)&type=Server", &match)
            shareCode := match[1]
        
        if linkCode {
        DeepLink := "roblox://placeID=" PlaceID "&linkCode=" linkCode
        } else if shareCode {
            DeepLink := "https://www.roblox.com/share?code=" shareCode "&type=Server"
        } else {
            DeepLink := "roblox://placeID=" PlaceID
        }
        try Run DeepLink

        loop 60 {
            if GetRobloxHWND() {
                Sleep(500)
                for hwnd in WinGetList(,, "Program Manager")
                {
                    p := WinGetProcessName("ahk_id " hwnd)
                    if (InStr(p, "Roblox") || InStr(p, "AutoHotkey"))
                        continue ; skip roblox and AHK windows
                    title := WinGetTitle("ahk_id " hwnd)
                    if (title = "")
                        continue ; skip empty title windows
                    s := WinGetStyle("ahk_id " hwnd)
                    if ((s & 0x8000000) || !(s & 0x10000000))
                        continue ; skip NoActivate and invisible windows
                    s := WinGetExStyle("ahk_id " hwnd)
                    if ((s & 0x80) || (s & 0x40000) || (s & 0x8))
                        continue ; skip ToolWindow and AlwaysOnTop windows
                    try
                    {
                        WinActivate "ahk_id " hwnd
                        WinMaximize("ahk_id " hwnd)
                        Sleep 500
                        Send "^{w}"
                    }
                    break
                }
                Sleep(500)
                ActivateRoblox()
                Sleep(25000)
                ActivateRoblox()
                ResizeRoblox()
                GetRobloxClientPos(GetRobloxHWND())
                MouseMove windowX + windowWidth//2, windowY + windowHeight//2
                Sleep(500)
                Click
                Click
                PlayerStatus("Game Succesfully loaded", "0x00a838", ,false)
                Sleep(1000)
                Send("{Tab}")
                Send("1")
                Sleep(300)
                CloseChat()
                Sleep(1500)
                return 1
            }
            Sleep(1000)
        }
        if (A_Index == 60){
            Sleep(500)
            for hwnd in WinGetList(,, "Program Manager")
            {
                p := WinGetProcessName("ahk_id " hwnd)
                if (InStr(p, "Roblox") || InStr(p, "AutoHotkey"))
                    continue ; skip roblox and AHK windows
                title := WinGetTitle("ahk_id " hwnd)
                if (title = "")
                    continue ; skip empty title windows
                s := WinGetStyle("ahk_id " hwnd)
                if ((s & 0x8000000) || !(s & 0x10000000))
                    continue ; skip NoActivate and invisible windows
                s := WinGetExStyle("ahk_id " hwnd)
                if ((s & 0x80) || (s & 0x40000) || (s & 0x8))
                    continue ; skip ToolWindow and AlwaysOnTop windows
                try
                {
                    WinActivate "ahk_id " hwnd
                    WinMaximize("ahk_id " hwnd)
                    Sleep 500
                    Send "^{w}"
                }
                break
            }
            Sleep(500)
        }
        Gdip_DisposeImage(pBMScreen)
        return 0

    } else {
        Gdip_DisposeImage(pBMScreen)
        return 0
    }
}

CloseChat(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth * 0.25 "|" windowHeight //8)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Chat"] , &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY
        MouseMove(x, y)
        Sleep(300)
        Click
    }
    Gdip_DisposeImage(pBMScreen)
}



openBag(){  
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth * 0.5 "|" windowHeight //8)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Openbag"] , &OutputList, , , , , 100,,8) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX + 2
        y := Cords[2] + windowY + 2
        MouseMove(x, y)
        Sleep(300)
        Click
        Sleep(500)
    }
    Gdip_DisposeImage(pBMScreen)
}

closeBag(){
    relativeMouseMove(0.95, 0.5)
    Click
    Sleep(500)
}

Closelb(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX + windowWidth - 300  
    capY := windowY                      
    capW := 300                          
    capH := 200                          
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Leaderboard"], , , , , , 50) = 1) {
        Send("{Tab}")
        Sleep(100)
        Gdip_DisposeImage(pBMScreen)
        return true
    }
    Gdip_DisposeImage(pBMScreen)
    return false 
}


clearSearch(){
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 "|" windowY + 30 "|" windowWidth // 2 "|" windowHeight - 30)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["x"] , &OutputList, , , , , 25,,3) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["x2"] , &OutputList, , , , , 25,,3) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX + windowWidth // 2 
        y := Cords[2] + windowY + 31
        MouseMove(x, y)
        Sleep(750)
        Click
        Click
        Sleep(250)
        Send("{Backspace}")
        Sleep(500)
    }
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Favorite"] , &OutputList, , , , , 20,,6) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX + windowWidth // 2 
        y := Cords[2] + windowY + 30
        MouseMove(x, y)
        Sleep(750)
        Click
        Sleep(500)
    }
    Gdip_DisposeImage(pBMScreen)
}


searchItem(keyword){
    keyword := StrReplace(keyword, " ", "%S+")
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    openBag()
    Sleep(1000)
    clearSearch()
    Sleep(1000)
    cordx := 0
    cordy := 0
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight )
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Search"] , &OutputList, , , , , 50) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY
        cordx := x
        cordy := y
        MouseMove(x, y)
        Sleep(300)
        Click
        Sleep(500)
        Send(keyword)
        Sleep(500)
        Gdip_DisposeImage(pBMScreen)
    } else {
        PlayerStatus("Could not detect Search in inventory", "0xFF0000")
        Gdip_DisposeImage(pBMScreen)
    }
}

clickItem(keyword, searchbitmap){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    Sleep(500)
    if (searchbitmap == "Bracket"){
        capX := windowX
        capY := windowY + 200 + windowHeight - 600
        capW := windowWidth
        capH := windowHeight - (400 + windowHeight - 600)
        pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
        if (Gdip_ImageSearch(pBMScreen, bitmaps["Bracket2"], &OutputList, , , , , 20) = 1) {
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + capX + 4
            y := Cords[2] + capY + 4
            MouseMove(x, y)
            Sleep(250)
            Click
            Sleep(250)
            Gdip_DisposeImage(pBMScreen)
            closeBag()
            return true
        }
        Gdip_DisposeImage(pBMScreen)
    }
    capX := windowX
    capY := windowY + 200 + windowHeight - 600
    capW := windowWidth
    capH := windowHeight - (200 + windowHeight - 600)
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)

    if (Gdip_ImageSearch(pBMScreen, bitmaps[searchbitmap], &OutputList, , , , , 20) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + capX + 4
        y := Cords[2] + capY + 4
        MouseMove(x, y)
        Sleep(250)
        Click
        Sleep(250)
        Gdip_DisposeImage(pBMScreen)
        if !(searchbitmap == "Recall Wrench"){
            closeBag()
        }
        return true
    } else {
        PlayerStatus("Missing " keyword " in inventory!", "0xff0000")
        Gdip_DisposeImage(pBMScreen)
        closeBag()
        return false
    }
}


clickCategory(category){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX
    capY := windowY + 200 + windowHeight - 600
    capW := windowWidth
    capH := windowHeight - (200 + windowHeight - 600)
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps[category] , &OutputList, , , , , 100) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + capX
        y := Cords[2] + capY
        MouseMove(x, y)
        Sleep(300)
        Click
    }
    Gdip_DisposeImage(pBMScreen)
}





CheckSetting(item,value){
    if (IniRead(settingsFile, item, value) == 1){
        return true
    }
    return false
}


relativeMouseMove(relx, rely) {
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    moveX := windowX + Round(relx * windowWidth)
    moveY := windowY + Round(rely * windowHeight)
    MouseMove(moveX,moveY)
}


Clickbutton(button, clickit := 1){
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)    
    
    if (button == "Garden" || button == "Sell" || button == "Seeds"){
        capX := windowX + (windowWidth // 4)
        capY := windowY + 30
        capW := windowWidth // 2
        capH := 100
        varation := 10
    } else if (button == "Xbutton") {
        capX := windowX + windowWidth * 0.60
        capY := windowY + windowHeight * 0.15
        capW := windowWidth * 0.38
        capH := windowHeight * 0.25
        varation := 60
    } else if (button == "Robux"){
        capX := windowX windowWidth // 4
        capY := windowY 
        capW := windowWidth //2
        capH := windowHeight
        varation := 10
    }

    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps[button], &OutputList, , , , , varation,,7) = 1) {
        if (clickit == 1){
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + capX - 2
            y := Cords[2] + capY 
            MouseMove(x, y)
            Sleep(10)
            Click
        }
        Gdip_DisposeImage(pBMScreen)
        return 1
    }
    Gdip_DisposeImage(pBMScreen)
    return 0
}

ChangeCamera(type){
    Send("{" EscKey "}")
    HyperSleep(750)
    Send("{Tab}")
    HyperSleep(333)
    Send("{Down}")
    HyperSleep(333)
    Send("{Right}")
    HyperSleep(333)
    Send("{Right}")
    HyperSleep(333)
    checkCamera(type)
    Send("{" EscKey "}")
    HyperSleep(1000)
}


checkCamera(type){  
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    loop 8 {
        pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)
        if (Gdip_ImageSearch(pBMScreen, bitmaps[type] , , , , , , 25) = 1) {
            Gdip_DisposeImage(pBMScreen)
            return 1
        } else {
            Send("{Right}")
            Sleep(1000)
            Gdip_DisposeImage(pBMScreen)
        }
    }

}


Closelb(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX + windowWidth - 300  
    capY := windowY                      
    capW := 300                          
    capH := 200                          
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Leaderboard"], , , , , , 50) = 1) {
        Send("{Tab}")
        Sleep(100)
        Gdip_DisposeImage(pBMScreen)
        return true
    }
    Gdip_DisposeImage(pBMScreen)
    return false 
}


ZoomAlign(){
    relativeMouseMove(0.5,0.5)
    Click
    Loop 40 {
        Send("{WheelUp}")
        Sleep 20
    }

    Sleep(500)
    Loop 6 {
        Send("{WheelDown}")
        Sleep 50
    }
    Sleep(100)
    Click
    Sleep(250)
}


CameraCorrection(){
    if (Disconnect()){
        Sleep(1500)
        equipRecall()
        Sleep(500)
    }
    Clickbutton("Garden")
    CloseClutter()
    Sleep(300)
    ChangeCamera("Follow")

    ZoomAlign()

    Click("Right", "Down")
    Sleep(200)
    relativeMouseMove(0.5, 0.5)
    Sleep(200)
    MouseMove(0, 800, 10, "R")
    Sleep(200)
    Click("Right", "Up")
    Sleep(250)

    loop 10 {
        Clickbutton("Sell") 
        Clickbutton("Seeds") 
    }
    Sleep(500)
    Clickbutton("Seeds")
    Sleep(250)

    ChangeCamera("Classic")
    Sleep(1000)
    relativeMouseMove(0.5,0.5)
    Sleep(500)
    PlayerStatus("Finished Aligning!","0x2260e6",,false,,false)
}

SpamClick(amount){
    loop amount {
        Click
        Sleep 20
    }
}






CheckStock(index, list, crafting := false){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    captureWidth := 150
    captureHeight := windowHeight // 2 + 100

    captureX := windowX + (windowWidth // 2) - (captureWidth // 2) - 150
    captureY := windowY + (windowHeight // 2) - (captureHeight // 2) + 20

    pBMScreen := Gdip_BitmapFromScreen(captureX "|" captureY "|" captureWidth "|" captureHeight)
    If (Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock"], &OutputList, , , , , 3,,3) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock2"], &OutputList , , , , , 3,,3) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + captureX - 2
        y := Cords[2] + captureY - 10
        MouseMove(x, y)
        Sleep(25)
        Click
        Gdip_DisposeImage(pBMScreen)
    } else {
        Gdip_DisposeImage(pBMScreen)
        return 0
    }

    loop {
        pBMScreen := Gdip_BitmapFromScreen(captureX "|" captureY "|" captureWidth "|" captureHeight)
        If (Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock"], &OutputList, , , , , 3,,3) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock2"], &OutputList , , , , , 3,,3) = 1) {
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + captureX - 5
            y := Cords[2] + captureY - 10
            MouseMove(x, y)
            Click
            Gdip_DisposeImage(pBMScreen)
            Sleep(25)
        } else {
            Gdip_DisposeImage(pBMScreen)
            PlayerStatus("Bought " list[index] "s!", "0x22e6a8",,false)
            return 1
        }
        if (A_index >= 5){
            SpamClick(5)
        }

        if (A_index == 50) {
            Gdip_DisposeImage(pBMScreen)
            return 0
        }
    }

}

buyShop(itemList, itemType, crafting := false){
    if (itemType == "Event" || itemType == "Eggs" || itemType == "Eggs2"){
        pos := 0.8
    } else {
        pos := 0.835
    }
    if (itemType == "Seeds") {
        tierHandler(1,"Seeds")
    } else if (itemType == "Seeds2"){
        tierHandler(2,"Seeds")
    } else if (itemType == "Eggs"){
        tierHandler(1,"Eggs")
    } else if (itemType == "Eggs2"){
        tierHandler(2,"Eggs")
    }

    for (item in itemlist){
        if (A_index == 1){
            if (crafting){
                relativeMouseMove(0.65,0.4)  
                Sleep(250)
                Click
                Sleep(250)
                Click
                Sleep(250)
            } 
            relativeMouseMove(0.4,pos)
            Loop itemList.length * 2 {
                Send("{WheelUp}")
                Sleep 20
            }
            Sleep(250)
            Click
            Sleep(250)
            Loop 12 {
                Send("{WheelUp}")
                Sleep 20
            }
            relativeMouseMove(0.5,0.4)
            Sleep(250)
        } else {
            relativeMouseMove(0.4,pos)
        }
        if (A_index >= 16 && itemType == "Gears"){
        ; if (A_index >= 18 && itemType != "Seeds"){
            ; if ((A_Index - 19) / 8 == 0.5){
            ;     ScrollDown(0.75)
            ;     Sleep(250)
            ; } else {
            ;     ScrollDown(0.25  + (A_Index - 19) / 8)
            ;     Sleep(250)
            ; }
            ScrollDown(0.25)
            Sleep(250)
        }
        Click
        Sleep(350)
        if (A_Index >= 23 && itemType != "Seeds") {
            ScrollDown(0.25)
            Sleep(250)
        }
        if (CheckSetting(itemType, StrReplace(item, " ", ""))){
            CheckStock(A_Index, itemlist, crafting)
        } else {
            Sleep(200)
        }
    }
    CloseShop(crafting)
}


ScrollDown(amount := 1) {
    BaseHeight := 1080

    ; Scale factor (based mostly on height, since scroll is vertical)
    Scale := WindowHeight / BaseHeight

    AdjustedAmount := Round(-amount * 120 * Scale)

    DllCall("user32.dll\mouse_event"
        , "UInt", 0x0800   ; MOUSEEVENTF_WHEEL
        , "UInt", 0
        , "UInt", 0
        , "UInt", AdjustedAmount
        , "UPtr", 0)
}



DetectShop(shop){
    loop 15 {
        Sleep(500)
        if (Clickbutton("Xbutton",0) == 1){
            Sleep(2500)
            PlayerStatus("Detected " shop " shop opened", "0x22e6a8",,false,,false)
            return 1
        }
    }
    PlayerStatus("Failed to open " shop " shop", "0x22e6a8",,false,,true)
    return 0
}


CloseShop(crafting := false){
    if (crafting == True){
        return 1
    }
    loop 15 {
        Sleep(500)
        if (Clickbutton("Xbutton") == 1){
            Sleep(1000)
            PlayerStatus("Closed shop!", "0x22e6a8",,false,,false)
            return 1
        }
    }
    PlayerStatus("Failed to close shop.", "0xFF0000",,false,,true)
    return 0

}





CloseClutter(){
    Clickbutton("Xbutton")
    Sleep(200)
    Clickbutton("Robux")
    Sleep(100)
}

getItems(item){
    static fileContent := ""

    if !fileContent {
        try {
            request := ComObject("WinHttp.WinHttpRequest.5.1")
            request.Open("GET", "https://raw.githubusercontent.com/epicisgood/GAG-Updater/refs/heads/main/items.json", true)
            request.Send()
            request.WaitForResponse()
            fileContent := JSON.parse(request.ResponseText)
            global MyWindow
            MyWindow.ExecuteScriptAsync("document.querySelector('#random-message').textContent = '" fileContent["message"] "'")
            
        } catch as e {
            PlayerStatus("This is a very rare error! " e.Message, "0xFF0000",,true,,false)
        }
    }
    names := []
    for itemObj in fileContent[item] {
        names.Push(itemObj["name"])
    }
    return names
    ; jsonData := fileContent
    ; return jsonData[item]
}

initShops(){
    static Shopinit := true
    static Seeds2init := true
    static Eggs2init := true
    static Egginit := true
    static Merchantinit := true
    static Cosemticinit := true
    if (Shopinit == true){
        if ((Mod(A_Min, 10) = 3 || Mod(A_Min, 10) = 8)) {
            global LastShopTime := nowUnix()
            BuySeeds()
            BuyGears()
            BuyEvoSeeds()
            Shopinit := false
        }
    } else if (Egginit == true){
        if (A_Min == 22 || A_Min == 52) {
            global LastEggsTime := nowUnix()
            BuyEggs()
            Egginit := false
        }
    } else if (Merchantinit == true){
        if (A_min < 5) {
            global LastMerchantTime := nowUnix()
            BuyMerchant()
            Merchantinit := false
        }
    } else if (Cosemticinit == true){
        UtcNow := A_NowUTC
        UtcHour := FormatTime(UtcNow, "H")
        if (Mod(UtcHour, 4) == 0 && A_min < 5) {
            global LastCosmetics := nowUnix()
            BuyCosmetics()
            Cosemticinit := false
        }
    } else if (Seeds2init == true){
        if (A_min < 5) {
            global LastSeeds2 := nowUnix()
            BuySeeds2()
            Seeds2init := false
        }
    } else if (Eggs2init == true){
        if (A_Min == 22 || A_Min == 52) {
            global LastEggs2 := nowUnix()
            BuyEggs2()
            Eggs2init := false
        }
    }


}

BuySeeds(){
    seedItems := getItems("Seeds")
    if !(CheckSetting("Seeds", "Seeds")){
        return
    }
    loop 3 {
        PlayerStatus("Going to buy Seeds!", "0x22e6a8",,false,,false)
        relativeMouseMove(0.5, 0.5)
        Sleep(500)
        Clickbutton("Seeds")
        Sleep(1000)
        Send("{" Ekey "}")
        if !DetectShop("Seeds"){
            CameraCorrection()
            continue
        }
        buyShop(seedItems, "Seeds")
        CloseClutter()
        return 1
    }
    PlayerStatus("Failed to buy seeds 3 times, CLOSING ROBLOX!", "0x001a12")
    CloseRoblox()
}






BuyGears(){
    gearItems := getItems("Gears")
    if !(CheckSetting("Gears", "Gears")){
        return
    }
    loop 3 {
        PlayerStatus("Going to buy Gears!", "0x22e6a8",,false,,false)
        ActivateRoblox()
        Clickbutton("Garden")
        Sleep(500)
        Send("1")
        Sleep(300)
        relativeMouseMove(0.5, 0.5)
        Click
        Sleep(1500)
        Send("{" Ekey "}")
        if !DetectShop("gear"){
            CameraCorrection()
            continue
        }
        buyShop(gearItems, "Gears")
        CloseClutter()
        return 1
    }
    
    CloseClutter()
    Sleep(1500)
    equipRecall()
    PlayerStatus("Equiped recall wrench, failed to open gear shop 3 times.", "0x001a12")
}



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main Macro Functions.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Disconnect(){
    loop 3 {
        if (CheckDisconnnect()){
            return 1
        }
    }
}
GearCraftingTime := 10000000000
SeedCraftingTime := 10000000000
EventCraftingTime := 10000000000

MainLoop() {

    if (GetRobloxHWND()){
        ResizeRoblox()
    }
    
    if (Disconnect()){
        Sleep(1500)
        return
    }

    MyWindow.Destroy()
    CloseChat() 
    Closelb()
    equipRecall()
    CameraCorrection()
    CookingEvent()
    BuySeeds()
    BuySeeds2()
    BuyGears()
    BuyEggs()
    BuyEggs2()
    BuyEvoSeeds()
    ; BuyEvent()
    BuyCosmetics()
    global LastCookingTime := nowUnix()
    GearCraft()
    global LastGearCraftingTime := nowUnix()
    SeedCraft()
    global LastSeedCraftingTime := nowUnix()
    BuyMerchant()
    global LastEventCraftingtime := nowUnix()
    loop {
        initShops()
        
        if (((Mod(A_Min, 10) = 2 || Mod(A_Min, 10) = 7)) && A_Sec == 30) {
            CameraCorrection()
        }
        if ((Mod(A_Min, 10) = 3 || Mod(A_Min, 10) = 8)) {
            RewardInterupt()
        }
        if (Mod(A_Index, 30) == 0){
            CloseClutter()
            Closelb()
            if (Disconnect()){
                Sleep(1500)
                equipRecall()
                Sleep(500)
                CameraCorrection()
            }
        }
        ShowToolTip()
        Sleep(1000)
    }
    
    
    
}


ShowToolTip(){
    global LastShopTime
    global LastSeeds2Time
    global LastEggs2Time
    global LastEggsTime
    global LastEvoSeedsTime
    ; global LastfallCosmeticsTime
    ; global LastfallGearsTime
    ; global LastfallPetsTime
    global LastMerchantTime
    global LastGearCraftingTime
    global LastSeedCraftingTime
    global LastCookingTime

    global GearCraftingTime
    global SeedCraftingTime

    static SeedsEnabled := IniRead(settingsFile, "Seeds", "Seeds") + 0
    static Seeds2Enabled := IniRead(settingsFile, "Seeds2", "Seeds2") + 0
    static Eggs2Enabled := IniRead(settingsFile, "Eggs2", "Eggs2") + 0
    static GearsEnabled := IniRead(settingsFile, "Gears", "Gears") + 0
    static EggsEnabled := IniRead(settingsFile, "Eggs", "Eggs") + 0
    static EvoSeedsEnabled := IniRead(settingsFile, "EvoSeeds", "EvoSeeds") + 0
    ; static fallCosmeticsEnabled := IniRead(settingsFile, "fallCosmetics", "fallCosmetics") + 0
    ; static fallGearsEnabled := IniRead(settingsFile, "fallGears", "fallGears") + 0
    ; static fallPetsEnabled := IniRead(settingsFile, "fallPets", "fallPets") + 0
    static gearCraftingEnabled := IniRead(settingsFile, "GearCrafting", "GearCrafting") + 0
    static seedCraftingEnabled := IniRead(settingsFile, "SeedCrafting", "SeedCrafting") + 0
    static cosmeticEnabled := IniRead(settingsFile, "Settings", "Cosmetics") + 0
    static merchantEnabled := IniRead(settingsFile, "Settings", "TravelingMerchant") + 0
    static CookingEnabled := IniRead(settingsFile, "Settings", "CookingEvent") + 0


    currentTime := nowUnix()

    tooltipText := ""
    if (SeedsEnabled) {
        static SeedTime := 300
        SeedRemaining := Max(0, SeedTime - (currentTime - LastShopTime))
        tooltipText .= "Seeds: " (SeedRemaining // 60) ":" Format("{:02}", Mod(SeedRemaining, 60)) "`n"
    }
    if (Seeds2Enabled) {
        static Seed2Time := 3600
        Seed2Remaining := Max(0, Seed2Time - (currentTime - LastSeeds2Time))
        tooltipText .= "Seeds T2: " (Seed2Remaining // 60) ":" Format("{:02}", Mod(Seed2Remaining, 60)) "`n"
    }

    if (GearsEnabled) {
        static GearTime := 300
        GearRemaining := Max(0, GearTime - (currentTime - LastShopTime))
        tooltipText .= "Gears: " (GearRemaining // 60) ":" Format("{:02}", Mod(GearRemaining, 60)) "`n"
    }
    if (EvoSeedsEnabled) {
        static EvoSeedsTime := 300
        EvoSeedsRemaining := Max(0, EvoSeedsTime - (currentTime - LastShopTime))
        tooltipText .= "EvoSeeds: " (EvoSeedsRemaining // 60) ":" Format("{:02}", Mod(EvoSeedsRemaining, 60)) "`n"
    }
    ; if (fallCosmeticsEnabled) {
    ;     static fallCosmeticsTime := 3600
    ;     fallCosmeticsRemaining := Max(0, fallCosmeticsTime - (currentTime - LastfallCosmeticsTime))
    ;     tooltipText .= "fallCosmetics: " (fallCosmeticsRemaining // 60) ":" Format("{:02}", Mod(fallCosmeticsRemaining, 60)) "`n"
    ; }
    ; if (fallGearsEnabled) {
    ;     static fallGearsTime := 3600
    ;     fallGearsRemaining := Max(0, fallGearsTime - (currentTime - LastfallGearsTime))
    ;     tooltipText .= "fallGears: " (fallGearsRemaining // 60) ":" Format("{:02}", Mod(fallGearsRemaining, 60)) "`n"
    ; }
    ; if (fallPetsEnabled) {
    ;     static fallPetsTime := 3600
    ;     fallPetsRemaining := Max(0, fallPetsTime - (currentTime - LastfallPetsTime))
    ;     tooltipText .= "fallPets: " (fallPetsRemaining // 60) ":" Format("{:02}", Mod(fallPetsRemaining, 60)) "`n"
    ; }
    if (EggsEnabled) {
        static EggTime := 1800
        EggRemaining := Max(0, EggTime - (currentTime - LastEggsTime))
        tooltipText .= "Eggs: " (EggRemaining // 60) ":" Format("{:02}", Mod(EggRemaining, 60)) "`n"
    }
    if (Eggs2Enabled) {
        static Egg2Time := 1800
        Egg2Remaining := Max(0, Egg2Time - (currentTime - LastEggs2Time))
        tooltipText .= "Eggs T2: " (Egg2Remaining // 60) ":" Format("{:02}", Mod(Egg2Remaining, 60)) "`n"
    }
    if (CookingEnabled) {
        static CookingTime := Integer(IniRead(settingsFile, "Settings", "CookingTime") * 1.1)
        CookingRemaining := Max(0, CookingTime - (currentTime - LastCookingTime))
        cookingM := CookingRemaining // 60
        cookingS := Mod(CookingRemaining, 60)
        tooltipText .= "Cooking: " cookingM ":" Format("{:02}", cookingS) "`n"
    }
    if (cosmeticEnabled) {
        utcNow := A_NowUTC
        utcHour := FormatTime(utcNow, "H")
        utcMin := FormatTime(utcNow, "m")
        utcSec := FormatTime(utcNow, "s")

        totalSecNow := utcHour * 3600 + utcMin * 60 + utcSec
        nextcosmeticSec := Ceil(totalSecNow / (4 * 3600)) * 4 * 3600
        remainingSec := Mod(nextcosmeticSec - totalSecNow, 14400)  ; every 4 hours

        cosmeticH := remainingSec // 3600
        cosmeticM := Mod(remainingSec, 3600) // 60
        cosmeticS := Mod(remainingSec, 60)

        tooltipText .= "Cosmetics: " cosmeticH ":" Format("{:02}", cosmeticM) ":" Format("{:02}", cosmeticS) "`n"
    }
    if (merchantEnabled) {
        static merchantTime := 3600
        merchantRemaining := Max(0, merchantTime - (currentTime - LastMerchantTime))
        tooltipText .= "Merchant: " (merchantRemaining // 60) ":" Format("{:02}", Mod(merchantRemaining, 60)) "`n"
    }
    if (gearCraftingEnabled) {
        gearCraftRemaining := Max(0, GearCraftingTime - (currentTime - LastGearCraftingTime))
        gearM := gearCraftRemaining // 60
        gearS := Mod(gearCraftRemaining, 60)
        tooltipText .= "Gear Crafting: " gearM ":" Format("{:02}", gearS) "`n"
    }

    if (seedCraftingEnabled) {
        seedCraftRemaining := Max(0, SeedCraftingTime - (currentTime - LastSeedCraftingTime))
        seedM := seedCraftRemaining // 60
        seedS := Mod(seedCraftRemaining, 60)
        tooltipText .= "Seed Crafting: " seedM ":" Format("{:02}", seedS) "`n"
    }
    

    ToolTip(tooltipText, 100, 100)
}



F3::
{
    ; ActivateRoblox()
    ; ResizeRoblox()
    ; hwnd := GetRobloxHWND()
    ; GetRobloxClientPos(hwnd)
    ; pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    ; Gdip_SaveBitmapToFile(pBMScreen,"ss.png")
    ; Gdip_DisposeImage(pBMScreen)
    PauseMacro()
}

CookingEvent(){
    if !(CheckSetting("Settings", "CookingEvent")){
        return 0
    }

    PlayerStatus("Going to Cooking Event!", "0x22e6a8",,false,,false)
    Clickbutton("Garden")
    Sleep(1500)
    Send("{" Ekey "}")
    Send("{" Ekey "}")
    Sleep(2500)
    if (Clickbutton("Robux") == 1){
        PlayerStatus("Crafting not finished. Closing Robux prompt.","0xe67e22",,false)
        return 0
    }
    PlayerStatus("Claimed food!", "0x22e6a8",,false)
    searchListraw := IniRead(settingsFile, "Settings", "SearchList")
    searchList := StrSplit(searchListRaw, ",")
    for index, item in searchList {
        item := Trim(item)
        searchItem(item)
        Sleep(500)
        clickCategory("Fruit")
        Sleep(500)
        clickItem(item, "Bracket")
        Sleep(500)
        Send("{" Ekey "}")
        Send("{" Ekey "}")
        Sleep(500)
    }
    ZoomAlign()
    thing := 0.2
    loop 25 {
        thing += 0.025
        relativeMouseMove(0.5, thing)
        Click
    }
    CloseClutter()
    PlayerStatus("Cooking food!", "0x22e6a8",,false)
    Send("1")
    Sleep(250)
    Send("1")
}




BuyEvoSeeds(){
    if !(CheckSetting("EvoSeeds", "EvoSeeds")){
        return 0
    }

    PlayerStatus("Going to EvoSeeds Shop!", "0x22e6a8",,false,,false)

    searchItem("Event Lantern")
    clickItem("Event Lantern", "Event Lantern")

    Sleep(1500)
    Walk(500, Akey)
    Sleep(500)
    Send("{" Ekey "}")
    clickOption(2,5)
    if !DetectShop("EvoSeeds"){
        return 0 
    }
    buyShop(getItems("EvoSeeds"), "EvoSeeds")
    CloseClutter()
    return 1
}


; BuyfallGears(){
;     if !(CheckSetting("fallGears", "fallGears")){
;         return 0
;     }
;     PlayerStatus("Going to fallGears Shop!", "0x22e6a8",,false,,false)
;     if !DetectShop("fallGears"){
;         return 0 
;     }
;     buyShop(getItems("fallGears"), "fallGears")
;     CloseClutter()
;     return 1
; }

; BuyfallPets(){
;     if !(CheckSetting("fallPets", "fallPets")){
;         return 0
;     }
;     PlayerStatus("Going to fallPets Shop!", "0x22e6a8",,false,,false)
;     if !DetectShop("fallPets"){
;         return 0 
;     }
;     buyShop(getItems("fallPets"), "fallPets")
;     CloseClutter()
;     return 1
; }


; BuyfallCosmetics(){
;     if !(CheckSetting("fallCosmetics", "fallCosmetics")){
;         return 0
;     }
;     PlayerStatus("Going to fallCosmetics Shop!", "0x22e6a8",,false,,false)
;     if !DetectShop("fallCosmetics"){
;         return 0 
;     }
;     buyShop(getItems("fallCosmetics"), "fallCosmetics")
;     CloseClutter()
;     return 1
; }



