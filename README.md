# Submarine Portable — pacchetto winPenPack (X-Launcher)

**Versione pacchetto: 1.0b9**

## Correzioni nella 1.0b9

Dai due errori riscontrati compilando/avviando la 1.0b8, e su tua richiesta, ho semplificato l'impostazione partendo dal **codice sorgente generico** di X-Launcher 1.5.4 che hai allegato (`X-Launcher_source_1_5_4.zip`) invece che da quello ritagliato da X-Firefox, cambiando solo icona e informazioni di risorsa:

1. **`Submarine` diceva `APP_DATA_DIR_NOT_FOUND: unknown path`** → causato da un mix di due cose: la sezione `[FileSystem] Root=..` che avevo aggiunto, e il fatto che tenevi `X-Submarine.exe` in una sottocartella `XDrive` separata da `Bin\`/`User\`. **Rimossa la sezione `[FileSystem]`** come richiesto: ora valgono i default del motore (`Root` = cartella dove sta l'exe, `Home`/`Bin` = `.\User` e `.\Bin` relativi a quella cartella). Questo significa che **`X-Submarine.exe` deve stare allo stesso livello di `Bin\` e `User\`, senza alcuna sottocartella `XDrive` in mezzo** — esattamente come il pacchetto finito di X-Firefox che hai allegato in precedenza (`X-Firefox.exe`, `Bin\`, `User\` tutti fianco a fianco).
2. **Errore AutoIt "Unknown function name"** → bug noto di `Aut2exe.exe` con la compressione UPX (capita quando manca `AutoIt3Wrapper.exe` e si ripiega sul compilatore diretto). `Compila-Launcher.cmd` passa `/nopack` esplicito in quel fallback.

Il `[Environment]` è ora scritto nello stile "tradizionale" del template ufficiale (variabile `HOME` intermedia + riferimenti `%HOME%`), invece delle tre righe indipendenti di prima.

## Struttura

```
Readme/                        ← readme generici winPenPack, presi da X-Firefox (vedi sotto)
X-Submarine/                   ← sorgente da COMPILARE su Windows con AutoIt (vedi sotto)
├── X-Submarine.au3            ← script principale, compila in X-Submarine.exe
├── x-launcher.ini             ← configurazione (percorsi, primo avvio, ecc.)
├── x-launcher.au3             ← motore X-Launcher 1.5.4 (dal sorgente generico, invariato)
├── x-udf.au3
├── x-registry.au3
├── image_get_size.au3
├── files/
│   └── x-install.au3          ← funzione richiesta dal motore (qui vuota, Submarine non ha profili incorporati)
└── graphics/
    ├── x-icon.ico              ← icona segnaposto inclusa di default (vedi Estrai-Icona.cmd sotto)
    └── .icon-is-placeholder    ← marker: "questa icona è ancora quella generica"
Bin/
└── Submarine/
    ├── Init_Submarine.bat    ← download/estrazione di Submarine.exe da GitHub
    └── Submarine.exe         ← NON incluso: viene creato qui al primo avvio
User/
└── Submarine/
    ├── Profile/                  ← redirect di USERPROFILE
    └── AppData/
        ├── Roaming/              ← redirect di APPDATA
        └── Local/                ← redirect di LOCALAPPDATA
tools/
├── Compila-Launcher.cmd      ← compila X-Submarine.au3 in X-Submarine.exe
├── Estrai-Icona.cmd          ← sostituisce l'icona segnaposto con quella vera, se disponibile
├── Crea-Release.cmd          ← compila + impacchetta in releases\X-Submarine_<versione>_win32_<timestamp>.zip
└── Crea-Sorgenti.cmd         ← impacchetta X-Submarine\ e Readme\ in releases\X-Submarine_launcher_<versione motore>_rev<versione ini>.source.zip
.gitignore
README.md
```

Rispetto al pacchetto sorgente ufficiale di X-Firefox (che separa l'engine in una cartella `_x-launcher\` condivisa da più app), qui il motore sta **dentro** `X-Submarine\` insieme allo script specifico — layout flat, come nel sorgente generico che hai allegato. Avendo una sola app non serve condividere l'engine tra più launcher, e si evita ogni possibile ambiguità di percorso tra `X-Submarine.au3` e i file che include.

### Readme/

Contiene i readme generici del progetto winPenPack (autori, crediti, licenza, changelog di X-Launcher, ecc.), copiati identici da `X-Firefox_launcher_1.5.4_rev8_source.zip` — sono contenuti standard del framework, non specifici di un'app. L'unica eccezione è `release.txt`: quello di Firefox riporta versione/autore/licenza di Firefox, quindi l'ho riscritto con i dati di Submarine invece di copiarlo tale e quale (la licenza del progetto Submarine non l'ho potuta verificare, l'ho lasciata segnata come "non verificata").

## Passo 1 — Compilare il launcher (su Windows, con AutoIt)

1. Installa [AutoIt](https://www.autoitscript.com/) (include SciTE e Aut2Exe).
2. Il pacchetto include già un'icona segnaposto in `X-Submarine/graphics/x-icon.ico`, quindi puoi compilare subito. Per usare l'icona vera vedi `Estrai-Icona.cmd` più sotto (oppure sostituiscila a mano con una icona tua).
3. Apri `X-Submarine.au3` con SciTE ed esegui **Compile** (oppure Aut2Exe direttamente sul file). Verrà generato `X-Submarine.exe` nella stessa cartella `X-Submarine/`.

## Passo 2 — Posizionare i file (IMPORTANTE, cambiato in questa versione)

**Niente più cartella `XDrive`.** `X-Submarine.exe` e `x-launcher.ini` (rinominato `X-Submarine.ini`) vanno **allo stesso livello** delle cartelle `Bin\` e `User\`:

```
<dove metti il launcher>\
├── X-Submarine.exe
├── X-Submarine.ini
├── Bin\Submarine\...
└── User\Submarine\...
```

Se il tuo winPenPack ha già altre app con questo schema (una cartella comune con dentro tutti gli `X-*.exe` allo stesso livello di `Bin\` e `User\`, senza sottocartelle intermedie), mettiteci anche `X-Submarine.exe`/`.ini`. Se invece il tuo winPenPack usa una cartella `XDrive` separata per i launcher, **non funzionerà senza rimetterci la sezione `[FileSystem]`** — dimmelo e la reintroduco, stavolta dichiarando `Home=` e `Bin=` esplicitamente invece di `Root=..`.

## Compilazione e release automatiche

Nella cartella `tools/`:

- **`Estrai-Icona.cmd`** — richiamato automaticamente da `Compila-Launcher.cmd`. Il pacchetto include già un'icona segnaposto generica in `graphics\x-icon.ico` (così la compilazione funziona subito); se `Bin\Submarine\Submarine.exe` è già stato scaricato (basta eseguire una volta `Init_Submarine.bat`), estrae automaticamente la sua icona vera e la usa al posto del segnaposto. Se in seguito sostituisci l'icona a mano con una migliore (es. `src-tauri\icons\icon.ico` dal repository GitHub di Submarine), cancella anche `graphics\.icon-is-placeholder`: è il marker che dice allo script "questa è ancora quella generica, puoi sovrascriverla".
- **`Compila-Launcher.cmd`** — compila `X-Submarine.au3` in `X-Submarine.exe`. Cerca `AutoIt3Wrapper.exe` (che legge le direttive `#AutoIt3Wrapper_*` incorporate nel `.au3` — icona, versione, ecc.) nei percorsi standard di installazione, poi nel `PATH`, infine nella cartella indicata dalla variabile d'ambiente opzionale `WINPENPACK_AUTOIT_DIR`; se non lo trova, ripiega su `Aut2exe.exe` diretto con la stessa sequenza di ricerca (icona/versione applicate solo se `graphics\x-icon.ico` esiste), passando `/nopack` per evitare il bug UPX descritto sopra.
- **`Crea-Release.cmd`** — richiama prima `Compila-Launcher.cmd`, poi assembla in una cartella temporanea la struttura di distribuzione corretta (`X-Submarine.exe` + `X-Submarine.ini` alla radice, `Bin\Submarine\Init_Submarine.bat`, `User\Submarine\...` vuote) e la comprime con 7-Zip in `releases\X-Submarine_<versione>_win32_<timestamp>.zip`. La versione è letta da `x-launcher.ini` (`Ini Revision`, es. `1.0b9`); 7-Zip viene cercato nei percorsi standard di installazione, poi nel `PATH`, infine nella variabile d'ambiente opzionale `WINPENPACK_7ZIP` (percorso completo al tuo `7z.exe`, es. quello portabile di winPenPack).
- **`Crea-Sorgenti.cmd`** — impacchetta `X-Submarine\` e `Readme\` (senza l'`.exe` compilato) in `releases\X-Submarine_launcher_<versione motore>_rev<versione ini>.source.zip`, nello stesso formato del pacchetto sorgente ufficiale che hai allegato in precedenza (es. `X-Firefox_launcher_1.5.4_rev8.source.zip`; qui verrebbe `X-Submarine_launcher_1.5.4_rev1.0b9.source.zip`). Copia anche il nostro `README.md` di progetto dentro `Readme\` (come `README_X-Submarine.md`, senza sovrascrivere i readme generici).

Il `.gitignore` esclude `releases/`, tutti gli `.exe` compilati e i temporanei di build.

## Come funziona il primo avvio

Nessuno script VBS esterno: il motore X-Launcher gestisce il primo avvio in modo nativo tramite l'ini stesso:

1. `x-launcher.ini` ha `[Options] FirstRun=true`.
2. Al primo avvio di `X-Submarine.exe`, il motore esegue tutto quello che trova in `[FirstRunOperations]` — qui `RunFile=$Bin$\$AppName$\Init_Submarine.bat`, che scarica l'ultima release da GitHub, verifica il checksum se disponibile, estrae con 7-Zip e isola `Submarine.exe`.
3. Se `Init_Submarine.bat` **fallisce** (codice di uscita diverso da 0), il motore mostra un errore e **non** disattiva `FirstRun`: al prossimo avvio riprova.
4. Se ha successo, il motore stesso riscrive `x-launcher.ini` impostando `FirstRun=false`, così le esecuzioni successive saltano direttamente all'avvio di `Submarine.exe` (`[FileToRun]`).

> **7-Zip**: non incluso. `Init_Submarine.bat` lo cerca prima come installazione locale (`Program Files\7-Zip` o `(x86)`), poi come versione portabile in `winPenPack\Bin\7-Zip\7z.exe`.

## Variabili usate nell'ini

Senza sezione `[FileSystem]`, valgono i default del motore:

- `$Bin$` → `.\Bin` relativo alla cartella dove sta `X-Submarine.exe`
- `$Home$` → `.\User` relativo alla stessa cartella
- `$AppName$` → `Submarine` (definito in `[Setup]`)

`[Environment]` in stile tradizionale (variabile intermedia + riferimenti):
```
HOME=$Home$\$AppName$
USERPROFILE=%HOME%\Profile
APPDATA=%HOME%\AppData\Roaming
LOCALAPPDATA=%HOME%\AppData\Local
```

## Cosa NON ho potuto fare

- Non posso compilare `X-Submarine.exe` da qui (serve AutoIt su Windows) — quindi nemmeno verificare che queste correzioni risolvano davvero i tuoi errori: sono corrette in base al codice sorgente del motore che ho letto, ma non testate end-to-end.
- Non so con certezza come sia strutturato il tuo winPenPack reale rispetto a `XDrive` — ho assunto (in base al pacchetto finito di X-Firefox) che l'app vada tenuta allo stesso livello di `Bin\`/`User\`. Se il tuo setup richiede davvero una sottocartella `XDrive` separata, dimmelo e adeguo l'ini.
