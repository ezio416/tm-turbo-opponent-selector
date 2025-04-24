// c 2025-04-24
// m 2025-04-24

const string  pluginColor = "\\$FFF";
const string  pluginIcon  = Icons::Arrows;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Opponent"]
Opponent S_Opponent = Opponent::Alone;

[Setting category="General" name="Reload map on finish" description="Since the game doesn't give you the full menu after finishing, this allows for ghost selection"]
bool S_ReloadMapOnFinish = false;

enum Opponent {
    Gold,
    Silver,
    Bronze,
    Alone
}

void Main() {
    auto App = cast<CTrackMania>(GetApp());

    string lastUid, uid;

    while (true) {
        yield();

        auto Playground = cast<CTrackManiaRaceNew>(App.CurrentPlayground);

        if (false
            || !S_Enabled
            || App.Challenge is null
            || Playground is null
            || App.Editor !is null
        ) {
            lastUid = uid = "";
            continue;
        }

        uid = App.Challenge.EdChallengeId;
        if (true
            && uid.Length > 0
            && uid != lastUid
        ) {
            lastUid = uid;
            OnEnteredMapAsync();
        }

        if (true
            && S_ReloadMapOnFinish
            && App.Challenge.MapInfo !is null
            && Playground.UIConfigs.Length > 0
            && Playground.UIConfigs[0] !is null
            && Playground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound
        ) {
            Map(App.Challenge.MapInfo).Play();
        }
    }
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void OnEnteredMapAsync() {
    print("OnEnteredMap");

    auto App = cast<CTrackMania>(GetApp());

    const int64 start = Time::Stamp;

    while (true) {
        yield();

        if (Time::Stamp - start > 10) {
            warn("OnEnteredMap timed out");
            return;
        }

        auto Playground = cast<CTrackManiaRaceNew>(App.CurrentPlayground);
        if (Playground is null) {
            // warn("Playground");
            continue;
        }

        auto Interface = cast<CTrackManiaRaceInterface>(Playground.Interface);
        if (false
            || Interface is null
            || Interface.ManialinkPage is null
            || Interface.ManialinkPage.Childs.Length < 27
        ) {
            // warn("Interface");
            continue;
        }

        /*
        25 end race
        26 opponent selection
        27 pause
        30 insert coin
        */

        auto OpponentFrame = cast<CControlFrame>(Interface.ManialinkPage.Childs[26]);
        if (false
            || OpponentFrame is null
            || OpponentFrame.Childs.Length < 2
        ) {
            // warn("OpponentFrame");
            continue;
        }

        uint oppIndex = uint(S_Opponent) + 6;
        auto OpponentMenu = cast<CControlFrame>(OpponentFrame.Childs[1]);
        if (false
            || OpponentMenu is null
            || OpponentMenu.Childs.Length < oppIndex + 1
            || !OpponentMenu.IsVisible
            || !OpponentMenu.IsFocused
        ) {
            // warn("OpponentMenu");
            continue;
        }

        auto Opponent = cast<CControlFrame>(OpponentMenu.Childs[oppIndex]);
        if (false
            || Opponent is null
            || Opponent.Childs.Length < 2
        ) {
            // warn("Opponent");
            continue;
        }

        auto Button = cast<CControlQuad>(Opponent.Childs[1]);
        if (Button is null) {
            // warn("Button");
            continue;
        }

        Button.OnAction();
        print("selected opponent '" + tostring(S_Opponent) + "'");
        return;
    }
}

class Map {
    string name;
    string path;

    Map(CGameCtnChallengeInfo@ map) {
        name = map.Name;
        path = map.FileName;
    }

    void Play() {
        startnew(CoroutineFunc(PlayAsync));
    }

    void PlayAsync() {
        print("loading map " + name + " from path " + path);

        auto App = cast<CTrackMania>(GetApp());
        App.BackToMainMenu();
        while (!App.ManiaTitleFlowScriptAPI.IsReady)
            yield();
        App.ManiaTitleFlowScriptAPI.PlayMap(path, "TMC_CampaignSolo", "");
        while (!App.ManiaTitleFlowScriptAPI.IsReady)
            yield();
    }
}
