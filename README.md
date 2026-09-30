# IPHONE - iPhone 14 Safari ellenorzes Claude Code-hoz

Ez a kulonallo, nyilvanos **teszteszkoz** GitHub Mac gepen iPhone 14 Simulatort indit, az igazi iOS Safariban megnyit egy oldalt, majd kepernyokepet ment. A privat Model-Agency kod es a `.env.local` nem kerul a teszteszkoz repojaba. Sajat iPhone vagy Mac nem kell.

## Gyors inditas

Nyiss PowerShellt ebben a mappaban, majd:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-local.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\run-check.ps1
```

A masodik parancs a beepitett probaoldalt fenykepezi le. A kep az `artifacts\run-<azonosito>\screenshot.png` fajlba kerul, mellette `report.json` jelzi az eszkozt es az iOS runtime-ot. A GitHubon a munkafolyamat neve `iPhone Safari screenshot`.

Az elso indulaskor a szimulator felepitese tobb perc is lehet. A Cloudflare alagut uj cimenek elerhetosege is keshet nagyjabol egy-ket percet.

A mar mukodo Model-Agency tesztoldal ellenorzese:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-check.ps1 -Url 'https://model-agency-test.onrender.com/'
```

Ez a **kitelepitett tesztverziot** nezi. Nem feltetlenul tartalmazza az eppen szerkesztett helyi valtoztatasaidat. Bejelentkezes nelkul a login vagy nyilvanos oldal latszik.

## Helyi Model-Agency valtozat

Az aktualis kod egyetlen paranccsal indithato, ideiglenes Cloudflare alagutra kotheto es ellenorizheto:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-modelagency.ps1 -Page '/'
```

Alapertelmezett projektmappa: `C:\Users\adria\projects\Model-Agency`. Masik checkout eseten hasznald a `-ProjectPath` parametert. A script ellenorzi, hogy a `.env.local` ne az ismert eles adatbazisra mutasson, elinditja a projekt sajat `scripts\test-server.ps1` tesztszerveret, megvarja a GitHub Safari-futast, letolti a kepet, majd leallitja az altala inditott szervert es alagutat. A 3140-es port szabad kell legyen.

**Az alagut URL-je barkinek hozzaferest ad, aki ismeri, amig a futas tart.** Csak tesztadatokkal hasznald. Az URL a nyilvanos GitHub workflow bemeneteben is lathato; a folyamat vegen megszunik. A `bin\cloudflared.exe` a gepen van, a nyilvanos repoba nem kerul.

## Claude Code

Nyisd meg ezt a mappat Claude Code-ban, vagy add at neki a [CLAUDE.md](CLAUDE.md) utasitasait. A `run-check.ps1` vagy `run-modelagency.ps1` kimeneti kepet kell megneznie, majd a felismert hibara javitast javasolnia vagy a projektben javitania. Egy lenyeges UI valtoztatashoz egy kep es rovid riport eleg; csak javitas utan kell ujra futtatni.

## Korlatok es koltseg

- A GitHub szabvanyos Mac futtatoja nyilvanos repoban ingyenes. A Model-Agency privat repojanak Actions-kerete jelenleg elfogyott, ezert van kulon nyilvanos teszteszkoz.
- A Cloudflare Quick Tunnel tesztre ingyenesen hasznalhato, fiok es domain nelkul. Csak addig el, amig a folyamat fut.
- Ez valodi Safari **iOS Simulatorban**, de nem fizikai iPhone 14. Kamera, billentyuzet es egyes hardverreszletek elterhetnek.
- A munkafolyamat csak egy kepernyot ment. Bejelentkezett belso oldalakhoz kesobb kulon automatizalt bejelentkezes vagy teszt session szukseges.
- A teszt iOS 18.6 rendszert hasznal, mert az iOS 26 friss Safari-elsoinditasi sugoja eltakarja a kepernyo aljat az uj szimulatoron. Ha a GitHub Mac gepen az iPhone 14 vagy az iOS 18.6 mar nem elerheto, a futas hibaval leall.

Forrasok: [GitHub Mac futtatok](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), [Cloudflare Quick Tunnels](https://developers.cloudflare.com/tunnel/get-started/quick-tunnels/).
