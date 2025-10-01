-- Locale.lua
local Localisation = {}

local Structures = require("Union.UnionStructures")

-- For the Early releases of this mod, force the english localisation.
-- Later versions will support the game's 13 languages when users are able to vet the machine translations, as of now they're not accessible.
local force_english = true

local LocalisationKey = {
    En = {
        presence_menu_offline   = "Idling in the Main Menu",
        presence_menu_online    = "Idling in an Online Lobby",
        presence_jukebox        = "Layin’ the Wax and Spinnin' the sound!",
        presence_courseselect   = "Selecting a Course",
        presence_prixselect     = "Selecting a Grand Prix",
        presence_class          = "Selecting a Speed Class",
        presence_racerselect    = "Selecting a Character & Machine",
        presence_friendmatch    = "Friend Match",
        presence_paused         = "Game Paused",
        presence_garage         = "Customizing a Machine",
        presence_finish         = "Race Finished",
        presence_uniondiscord   = "UnionDiscord %s",
        presence_mainmenu       = "Main Menu",
        presence_grandprix      = "Grand Prix",
        presence_timetrial      = "Time Trial",
        presence_partyrace      = "Race Park",
        presence_rankmatch      = "World Match",
        presence_fest           = "Festival",
        presence_legend         = "Legend Competition",
        presence_wait           = "Waiting",
        presence_racing         = "Racing at %s",
        presence_normalspeed    = "a Normal Speed",
        presence_highspeed      = "High Speed",
        presence_sonicspeed     = "Sonic Speed",
        presence_supersonicspeed = "Super Sonic Speed!",
    },
    
    -- Machine Assisted Translation: red1fouad (28-09-2025)
    Ja = {
        presence_menu_offline   = "メインメニューで待機中",
        presence_menu_online    = "オンラインロビーで待機中",
        presence_jukebox        = "レコードをかけてサウンドを楽しんでいる！",
        presence_courseselect   = "コースを選択中",
        presence_grandprix      = "グランプリを選択中",
        presence_class          = "スピードクラスを選択中",
        presence_racerselect    = "キャラクターとマシンを選択中",
        presence_friendmatch    = "フレンドマッチ",
        presence_paused         = "ゲームを一時停止中",
        presence_garage         = "マシンをカスタマイズ中",
        presence_finish         = "レース終了",
        presence_uniondiscord   = "UnionDiscord %s",
    },
    
    -- Translated by: red1fouad (27-09-2025)
    Fr = {
        presence_menu_offline   = "Inactif dans le menu principal",
        presence_menu_online    = "Inactif dans un salon en ligne",
        presence_jukebox        = "Pose le vinyle et fait tourner le son !",
        presence_courseselect   = "Sélection d’un circuit",
        presence_grandprix      = "Sélection d’un Grand Prix",
        presence_class          = "Sélection d’une classe de vitesse",
        presence_racerselect    = "Sélection d’un personnage et d’une machine",
        presence_friendmatch    = "Partie entre amis",
        presence_paused         = "Jeu en pause",
        presence_garage         = "Personnalisation d’une machine",
        presence_finish         = "Course terminée",
        presence_uniondiscord   = "UnionDiscord %s",
    },

    -- Machine Translation
    It = {
        presence_menu_offline   = "Inattivo nel menu principale",
        presence_menu_online    = "Inattivo in una lobby online",
        presence_jukebox        = "Metti il vinile e fai girare la musica!",
        presence_courseselect   = "Selezionando un percorso",
        presence_grandprix      = "Selezionando un Gran Premio",
        presence_class          = "Selezionando una classe di velocità",
        presence_racerselect    = "Selezionando un personaggio e una macchina",
        presence_friendmatch    = "Partita con amici",
        presence_paused         = "Gioco in pausa",
        presence_garage         = "Personalizzazione di una macchina",
        presence_finish         = "Gara terminata",
        presence_uniondiscord   = "UnionDiscord %s",
    },
    
    -- Translated by: a5tronomy (27-09-2025)
    De = {
        presence_menu_offline   = "Im Hauptmenü",
        presence_menu_online    = "In einer Online-Lobby",
        presence_jukebox        = "Hört Musik im Jukebox-Modus",
        presence_courseselect   = "Wählt eine Strecke",
        presence_grandprix      = "Wählt einen Grand Prix",
        presence_class          = "Wählt eine Geschwindigkeitsklasse",
        presence_racerselect    = "Wählt Charakter und Maschine",
        presence_friendmatch    = "Freundschaftsspiel",
        presence_paused         = "Spiel pausiert",
        presence_garage         = "Passt eine Maschine an",
        presence_finish         = "Rennen abgeschlossen",
    },

    -- Translated by: red1fouad (27-09-2025)
    Es = {
        presence_menu_offline   = "Inactivo en el menú principal",
        presence_menu_online    = "Inactivo en una sala en línea",
        presence_jukebox        = "¡Poniendo vinilos y girando el sonido!",
        presence_courseselect   = "Seleccionando un circuito",
        presence_grandprix      = "Seleccionando un Gran Premio",
        presence_class          = "Seleccionando una clase de velocidad",
        presence_racerselect    = "Seleccionando un personaje y una máquina",
        presence_friendmatch    = "Partida con amigos",
        presence_paused         = "Juego en pausa",
        presence_garage         = "Personalizando una máquina",
        presence_finish         = "Carrera terminada",
        presence_uniondiscord   = "UnionDiscord %s",
    },

    -- Translated by: red1fouad (27-09-2025)
    EsUS = {
        presence_menu_offline   = "Inactivo en el menú principal",
        presence_menu_online    = "Inactivo en un lobby en línea",
        presence_jukebox        = "¡Tocando vinilos y girando el ritmo!",
        presence_courseselect   = "Seleccionando una pista",
        presence_grandprix      = "Seleccionando un Gran Premio",
        presence_class          = "Seleccionando una clase de velocidad",
        presence_racerselect    = "Seleccionando un personaje y una máquina",
        presence_friendmatch    = "Partida con amigos",
        presence_paused         = "Juego en pausa",
        presence_garage         = "Personalizando una máquina",
        presence_finish         = "Carrera terminada",
        presence_uniondiscord   = "UnionDiscord %s",
    },

    -- Machine Translation
    Ru = {
        presence_menu_offline   = "В главном меню бездействует",
        presence_menu_online    = "Бездействует в онлайн-лобби",
        presence_jukebox        = "Крутит пластинку и включает звук!",
        presence_courseselect   = "Выбор трассы",
        presence_grandprix      = "Выбор Гран-при",
        presence_class          = "Выбор класса скорости",
        presence_racerselect    = "Выбор персонажа и машины",
        presence_friendmatch    = "Игра с друзьями",
        presence_paused         = "Игра на паузе",
        presence_garage         = "Настройка машины",
        presence_finish         = "Гонка завершена",
        presence_uniondiscord   = "UnionDiscord %s",
    },

    -- Machine Translation
    Pl = {
        presence_menu_offline   = "Bezczynny w menu głównym",
        presence_menu_online    = "Bezczynny w lobby online",
        presence_jukebox        = "Zakłada winyl i puszcza muzykę!",
        presence_courseselect   = "Wybór trasy",
        presence_grandprix      = "Wybór Grand Prix",
        presence_class          = "Wybór klasy prędkości",
        presence_racerselect    = "Wybór postaci i pojazdu",
        presence_friendmatch    = "Mecz towarzyski",
        presence_paused         = "Gra wstrzymana",
        presence_garage         = "Dostosowywanie pojazdu",
        presence_finish         = "Wyścig zakończony",
        presence_uniondiscord   = "UnionDiscord %s",
    },

    -- Machine Translation
    Pt = {
        presence_menu_offline   = "Inativo no menu principal",
        presence_menu_online    = "Inativo em um lobby online",
        presence_jukebox        = "Colocando o vinil e girando o som!",
        presence_courseselect   = "Selecionando uma pista",
        presence_grandprix      = "Selecionando um Grande Prêmio",
        presence_class          = "Selecionando uma classe de velocidade",
        presence_racerselect    = "Selecionando um personagem e uma máquina",
        presence_friendmatch    = "Partida com amigos",
        presence_paused         = "Jogo pausado",
        presence_garage         = "Personalizando uma máquina",
        presence_finish         = "Corrida terminada",
        presence_uniondiscord   = "UnionDiscord %s",
    },

    -- Machine Translation
    Ko = {
        presence_menu_offline   = "메인 메뉴에서 대기 중",
        presence_menu_online    = "온라인 로비에서 대기 중",
        presence_jukebox        = "레코드를 돌리고 음악을 재생합니다!",
        presence_courseselect   = "코스 선택 중",
        presence_grandprix      = "그랑프리 선택 중",
        presence_class          = "속도 클래스를 선택 중",
        presence_racerselect    = "캐릭터와 머신 선택 중",
        presence_friendmatch    = "친구 매치",
        presence_paused         = "게임 일시 정지",
        presence_garage         = "머신 커스터마이즈 중",
        presence_finish         = "레이스 종료",
        presence_uniondiscord   = "UnionDiscord %s",
    },

    -- Machine Translation
    ZhHans = {
        presence_menu_offline   = "在主菜单中闲置",
        presence_menu_online    = "在在线大厅中闲置",
        presence_jukebox        = "放上唱片，播放音乐！",
        presence_courseselect   = "选择赛道",
        presence_grandprix      = "选择大奖赛",
        presence_class          = "选择速度等级",
        presence_racerselect    = "选择角色和赛车",
        presence_friendmatch    = "好友比赛",
        presence_paused         = "游戏已暂停",
        presence_garage         = "自定义赛车",
        presence_finish         = "比赛结束",
        presence_uniondiscord   = "UnionDiscord %s",
    },

    -- Machine Translation
    ZhHant = {
        presence_menu_offline   = "在主選單中閒置",
        presence_menu_online    = "在在線大廳中閒置",
        presence_jukebox        = "放上唱片，播放音樂！",
        presence_courseselect   = "選擇賽道",
        presence_grandprix      = "選擇大獎賽",
        presence_class          = "選擇速度等級",
        presence_racerselect    = "選擇角色和賽車",
        presence_friendmatch    = "好友比賽",
        presence_paused         = "遊戲已暫停",
        presence_garage         = "自定義賽車",
        presence_finish         = "比賽結束",
        presence_uniondiscord   = "UnionDiscord %s",
    },

    -- Machine Translation
    Th = {
        presence_menu_offline   = "ไม่ทำอะไรในเมนูหลัก",
        presence_menu_online    = "ไม่ทำอะไรในล็อบบี้ออนไลน์",
        presence_jukebox        = "ใส่แผ่นเสียงและเล่นเพลง!",
        presence_courseselect   = "เลือกสนามแข่ง",
        presence_grandprix      = "เลือกกรังด์ปรีซ์",
        presence_class          = "เลือกคลาสความเร็ว",
        presence_racerselect    = "เลือกตัวละครและเครื่อง",
        presence_friendmatch    = "แมทช์กับเพื่อน",
        presence_paused         = "เกมหยุดชั่วคราว",
        presence_garage         = "ปรับแต่งเครื่อง",
        presence_finish         = "การแข่งขันจบแล้ว",
        presence_uniondiscord   = "UnionDiscord %s",
    },
}

Localisation.GameModeMap = {
    None        = "presence_mainmenu",
    GrandPrix   = "presence_grandprix",
    PartyRace   = "presence_partyrace",
    TimeTrial   = "presence_timetrial",
    RankMatch   = "presence_rankmatch",
    FriendMatch = "presence_friendmatch",
    FriendMatch_NSW = "",
    Fest        = "presence_fest",
    Legend      = "presence_legend",
    Garage      = "presence_garage",
    Dev_FreeRun = "",
    Num         = "",
}

Localisation.SpeedClassMap = {
    NormalSpeed     = "presence_normalspeed",
    HighSpeed       = "presence_highspeed",
    SonicSpeed      = "presence_sonicspeed",
    SuperSonicSpeed = "presence_supersonicspeed",
}

function Localisation.GetGameModeText(mode_id)
    local key = Localisation.GameModeMap[mode_id]
    if not key or key == "" then
        return "" -- fallback for unmapped modes
    end

    return Localisation.T(key)
end

function Localisation.GetSpeedClassText(speed_id)
    local key = Localisation.SpeedClassMap[speed_id]
    if not key or key == "" then
        return "" -- fallback for unmapped modes
    end

    return Localisation.T(key)
end

local function T(key, ...)
    local loclibrary = StaticFindObject("/Script/UnionSystem.Default__LocalizationFunctionLibrary")
    local rawlang = loclibrary:GetTextLang()
    
    -- Force english for the beta release.
    local lang = nil
    if force_english then
        lang = "En"
    else
        lang = Structures.GetLanguageAsEnumFromID(rawlang)
    end
    local entry = LocalisationKey[lang][key]
    
    if not entry then
        return key -- fallback to key if not found
    end
    
    return string.format(entry, ...)
end

function Localisation.GetWaiting()
    return T("presence_wait")
end

Localisation.T = T

return Localisation
