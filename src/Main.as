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

        if (false
            || !S_Enabled
            || App.Challenge is null
            || App.CurrentPlayground is null
            || App.Editor !is null
        ) {
            lastUid = uid = "";
            continue;
        }

        uid = App.Challenge.EdChallengeId;
        if (uid.Length > 0 && uid != lastUid) {
            lastUid = uid;
            OnEnteredMap();
        }
    }
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void OnEnteredMap() {
    print("OnEnteredMap");

    auto App = cast<CTrackMania>(GetApp());

    const int64 start = Time::Stamp;

    while (true) {
        yield();

        if (Time::Stamp - start > 10) {
            warn("timed out");
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
