#Requires AutoHotkey v2.0
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
                loop 20 {
                    if (Clickbutton("Sell", 0) == 1){
                        break
                    }
                    Sleep(1000)
                    if (A_Index == 20) { 
                        CloseRoblox()
                        return 0
                    }
                }
                Sleep(1500)
                ResizeRoblox()
                GetRobloxClientPos(GetRobloxHWND())
                PlayerStatus("Game Succesfully loaded", "0x00a838", ,false)
                Sleep(1000)
                Send("{Tab}")
                CloseChat()
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

getItems(item){
    static fileContent := ""

    if !fileContent {
        try {
            request := ComObject("WinHttp.WinHttpRequest.5.1")
            request.Open("GET", "https://raw.githubusercontent.com/epicisgood/PVB-Updater/refs/heads/main/items.json", true)
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
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Openbag"] , &OutputList, , , , , 50,,8) = 1) {
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
    relativeMouseMove(0.95, 0.8)
    Click
    Sleep(500)
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
        capX := windowX + (windowWidth * 0.9)
        capY := windowY + (windowHeight * 0.25)
        capW := windowWidth * 0.1
        capH := windowHeight * 0.5
        varation := 10
    } else if (button == "Xbutton") {
        capX := windowX + windowWidth * 0.60
        capY := windowY + windowHeight * 0.1
        capW := windowWidth * 0.1
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
            y := Cords[2] + capY - 2
            MouseMove(x, y)
            Sleep(100)
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

    loop 5 {
        Clickbutton("Sell")
        Sleep(100)
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
    
    captureX := windowX + windowWidth * 0.43
    captureWidth := windowWidth * 0.1
    if (index == 1){
        captureY := windowY + windowHeight * 0.25
        captureHeight := windowHeight * 0.2
    } else if (index == 2){
        captureY := windowY + windowHeight * 0.45
        captureHeight := windowHeight * 0.2
    } else {
        captureY := windowY + windowHeight * 0.75
        captureHeight := windowHeight * 0.07
    }
    
    x := 0
    y := 0
    pBMScreen := Gdip_BitmapFromScreen(captureX "|" captureY "|" captureWidth "|" captureHeight)
    If (Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock"], &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + captureX 
        y := Cords[2] + captureY + 3
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
        If (Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock"], &OutputList , , , , , 25) = 1) {
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + captureX 
            y := Cords[2] + captureY + 3
            MouseMove(x, y)
            Click
            Gdip_DisposeImage(pBMScreen)
            Sleep(25)
        } else {
            Gdip_DisposeImage(pBMScreen)
            PlayerStatus("Bought " list[index] "s!", "0x22e6a8",,false)
            return 1
        }

        if (A_index == 20) {
            Gdip_DisposeImage(pBMScreen)
            return 0
        }
    }

}

buyShop(itemList, itemType, crafting := false){
    pos := 0.75

    for (item in itemlist){
        if (A_Index == 1) {
            relativeMouseMove(0.4,pos)
            Loop itemList.length * 2 {
                Send("{WheelUp}")
                Sleep 20
            }
        }

        if (CheckSetting(itemType, StrReplace(item, " ", ""))){
            CheckStock(A_Index, itemlist, crafting)
        }
        if !(A_Index == 1 || A_Index == 2){
            if (A_ScreenHeight == 600){
                ScrollDown(1.46)
            } else if (A_ScreenHeight == 768){
                ScrollDown(1.63)
                
            } else {
                ScrollDown(1.5825)
            }
        }
        Sleep(250)
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



initShops(){
    static Shopinit := true
    if (Shopinit == true){
        if (Mod(A_Min, 5) = 0 && (A_Sec >= 49)) {
            global LastShopTime := nowUnix()
            BuySeeds()
            BuyGears()
            Shopinit := false
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
        Walk(500,WKey)
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
        Clickbutton("Sell")
        Sleep(1000)
        Walk(400, Wkey)
        Sleep(500)
        Walk(750, AKey)
        Sleep(500)
        Sleep(500)
        Walk(250, Akey, Skey)
        Sleep(1000)
        Send("{" Ekey "}")
        if !DetectShop("gear"){
            CameraCorrection()
            continue
        }
        buyShop(gearItems, "Gears")
        CloseClutter()
        return 1
    }
    
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
    CameraCorrection()
    BuySeeds()
    BuyGears()
    EquipBestBrainrots()
    loop {
        initShops()
        if (((Mod(A_Min, 10) = 4 || Mod(A_Min, 10) = 9)) && A_Sec == 30) {
            CameraCorrection()
        }
        RewardInterupt()

        if (Mod(A_Index, 30) == 0){
            CloseClutter()
            Closelb()
            if (Disconnect()){
                Sleep(1500)
                CameraCorrection()
            }
        }
        ShowToolTip()
        Sleep(1000)
    }
    
    
    
}


ShowToolTip(){
    global LastShopTime

    static SeedsEnabled := IniRead(settingsFile, "Seeds", "Seeds") + 0
    static GearsEnabled := IniRead(settingsFile, "Gears", "Gears") + 0
    static invasionEnabled := IniRead(settingsFile, "Settings", "invasion") + 0
    static EquipBestEnabled := IniRead(settingsFile, "Settings", "EquipBest") + 0

    currentTime := nowUnix()

    tooltipText := ""
    if (SeedsEnabled) {
        static SeedTime := 300
        SeedRemaining := Max(0, SeedTime - (currentTime - LastShopTime))
        tooltipText .= "Seeds: " (SeedRemaining // 60) ":" Format("{:02}", Mod(SeedRemaining, 60)) "`n"
    }

    if (GearsEnabled) {
        static GearTime := 300
        GearRemaining := Max(0, GearTime - (currentTime - LastShopTime))
        tooltipText .= "Gears: " (GearRemaining // 60) ":" Format("{:02}", Mod(GearRemaining, 60)) "`n"
    }
    if (invasionEnabled) {
        static invasionTime := 2100
        invasionRemaining := Max(0, invasionTime - (currentTime - LastShopTime))
        tooltipText .= "invasion: " (invasionRemaining // 60) ":" Format("{:02}", Mod(invasionRemaining, 60)) "`n"
    }
    if (EquipBestEnabled) {
        static EquipBestTime := 300
        EquipBestRemaining := Max(0, EquipBestTime - (currentTime - LastShopTime))
        tooltipText .= "EquipBest: " (EquipBestRemaining // 60) ":" Format("{:02}", Mod(EquipBestRemaining, 60)) "`n"
    }


    ToolTip(tooltipText, 100, 100)
}


invasion(){
    if !(CheckSetting("Settings", "invasion")){
        return
    }
    PlayerStatus("Starting invasion!", "0x22e6a8",,false,,false)
    relativeMouseMove(0.5,0.5)
    Sleep(500)
    capX := windowX + (windowWidth * 0.9)
    capY := windowY + (windowHeight * 0.25)
    capW := windowWidth * 0.1
    capH := windowHeight * 0.225
    pbmScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pbmScreen, bitmaps["Battle"], &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + capx
        y := Cords[2] + capY
        MouseMove(x, y)
        Sleep(300)
        Click
        Sleep(500)
    } else {
        PlayerStatus("No Invasion found!", "0xe62222",,false,,false)
        Gdip_DisposeImage(pbmScreen)
        CloseClutter()
        return 0
    }

    Sleep(2000)
    Gdip_DisposeImage(pbmScreen)
    capX := windowX + (windowWidth * 0.525)
    capY := windowY + (windowHeight * 0.6)
    capW := windowWidth * 0.1
    capH := windowHeight * 0.3
    pbmScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pbmScreen, bitmaps["Battle"], &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + capx
        y := Cords[2] + capY
        PlayerStatus("Invasion Started!", "0x22e6a8",,false)
        MouseMove(x, y)
        Sleep(300)
        Click
        Sleep(500)
    } else {
        PlayerStatus("No Invasion found!", "0xe62222",,true)
        Gdip_DisposeImage(pbmScreen)
        CloseClutter()
        return 0
    }
    Gdip_DisposeImage(pbmScreen)
    CloseClutter()
    return 1

}

EquipBestBrainrots(){
    if !(CheckSetting("Settings", "EquipBest")){
        return
    }
    PlayerStatus("Getting cash!", "0x22e6a8",,false,,false)
    openBag()
    pbmScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)
    if (Gdip_ImageSearch(pbmScreen, bitmaps["Equip Best"], &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY - 3
        MouseMove(x, y)
        Sleep(300)
        Click
        Sleep(500)
    }
    Sleep(1000)
    closeBag()
    PlayerStatus("Collected Cash!", "0x22e6a8",,false,,false)
    CloseClutter()
    Gdip_DisposeImage(pbmScreen)
    return 1
}

F3::
{
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    PauseMacro()
}


