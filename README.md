# Submarine Portable — pacchetto winPenPack (X-Launcher)

Il tentativo precedente (X-Launcher.exe generico rinominato + script VBS esterno) **non è il modo corretto**: i launcher winPenPack (`X-Firefox.exe`, ecc.) non sono un unico eseguibile generico rinominato, ma vengono **compilati da sorgente AutoIt** per ogni singola app, con la propria configurazione incorporata. L'ho verificato sul pacchetto sorgente di X-Firefox 1.5.4 rev.8 che hai allegato e ho rifatto Submarine sullo stesso modello.

## Struttura

```
winPenPack/
├── _launcher-source/            ← sorgente da COMPILARE su Windows con AutoIt (vedi sotto)
│   ├── X-Submarine/
│   │   ├── X-Submarine.au3      ← script principale, compila in X-Submarine.exe
│   │   ├── x-launcher.ini       ← configurazione (percorsi, primo avvio, ecc.)
│   │   ├── files/
│   │   │   └── x-install.au3    ← funzione richiesta dal motore (qui vuota, Submarine non ha profili incorporati)
│   │   └── graphics/
│   │       └── LEGGIMI-icona.txt   ← manca x-icon.ico, vedi nota dentro
│   └── _x-launcher/              ← motore generico X-Launcher 1.5.4 (copiato invariato da X-Firefox, condiviso da tutte le app)
├── Bin/
│   └── Submarine/
│       ├── Init_Submarine.bat    ← download/estrazione di Submarine.exe da GitHub
│       └── Submarine.exe         ← NON incluso: viene creato qui al primo avvio
└── User/
    └── Submarine/
        ├── Profile/                  ← redirect di USERPROFILE
        └── AppData/
            ├── Roaming/              ← redirect di APPDATA
            └── Local/                ← redirect di LOCALAPPDATA
```

## Passo 1 — Compilare il launcher (su Windows, con AutoIt)

1. Installa [AutoIt](https://www.autoitscript.com/) (include SciTE e Aut2Exe).
2. Metti un'icona vera in `_launcher-source/X-Submarine/graphics/x-icon.ico`, oppure apri `X-Submarine.au3` e commenta la riga `#AutoIt3Wrapper_Icon=graphics\x-icon.ico`.
3. Apri `X-Submarine.au3` con SciTE ed esegui **Compile** (oppure Aut2Exe direttamente sul file). Verrà generato `X-Submarine.exe` nella stessa cartella `X-Submarine/`.
4. Copia `X-Submarine.exe` e `x-launcher.ini` (che devono stare **fianco a fianco**) nella cartella dove tieni gli altri launcher X- del tuo winPenPack (la stessa in cui, ad esempio, stanno `X-Firefox.exe` e il suo `x-launcher.ini`).

La cartella `_x-launcher/` (motore generico) deve restare presente **un livello sopra** quella cartella dei launcher — esattamente come nel pacchetto sorgente di X-Firefox che hai allegato — perché `X-Submarine.au3` la referenzia con `#include "..\_x-launcher\x-launcher.au3"`. Nel tuo winPenPack questa cartella è probabilmente già condivisa da tutti i launcher esistenti: non serve duplicarla, basta che `X-Submarine.au3` sia compilato nella stessa posizione relativa (un livello sotto `_x-launcher`) degli altri launcher-sorgente.

## Passo 2 — Copiare Bin/ e User/

Copia le cartelle `Bin/Submarine/` e `User/Submarine/` di questo pacchetto dentro il tuo `Bin/` e `User/` di winPenPack (accanto alle cartelle delle altre app, es. `Bin/Firefox/`).

## Compilazione e release automatiche

Nella cartella `tools/`:

- **`Estrai-Icona.cmd`** — richiamato automaticamente da `Compila-Launcher.cmd`. Il pacchetto include già un'icona segnaposto generica in `graphics\x-icon.ico` (così la compilazione funziona subito); se `Bin\Submarine\Submarine.exe` è già stato scaricato (basta eseguire una volta `Init_Submarine.bat`), estrae automaticamente la sua icona vera e la usa al posto del segnaposto. Se in seguito sostituisci l'icona a mano con una migliore (es. `src-tauri\icons\icon.ico` dal repository GitHub di Submarine), cancella anche `graphics\.icon-is-placeholder`: è il marker che dice allo script "questa è ancora quella generica, puoi sovrascriverla".
- **`Compila-Launcher.cmd`** — compila `X-Submarine.au3` in `X-Submarine.exe`. Cerca `AutoIt3Wrapper.exe` (che legge le direttive `#AutoIt3Wrapper_*` incorporate nel `.au3` — icona, versione, ecc.) nei percorsi standard di installazione, poi nel `PATH`, infine nella cartella indicata dalla variabile d'ambiente opzionale `WINPENPACK_AUTOIT_DIR`; se non lo trova, ripiega su `Aut2exe.exe` diretto con la stessa sequenza di ricerca (icona/versione applicate solo se `graphics\x-icon.ico` esiste).
- **`Crea-Release.cmd`** — richiama prima `Compila-Launcher.cmd`, poi assembla in una cartella temporanea la struttura di distribuzione corretta (`X-Submarine.exe` + `X-Submarine.ini` alla radice, `Bin\Submarine\Init_Submarine.bat`, `User\Submarine\...` vuote — stessa forma del pacchetto finito di X-Firefox che hai allegato) e la comprime con 7-Zip in `releases\X-Submarine_<versione>_win32_rev<revisione>_<timestamp>.zip`. Versione e revisione sono letti da `x-launcher.ini` (`Soft.Version`, `Ini Revision`); 7-Zip viene cercato nei percorsi standard di installazione, poi nel `PATH`, infine nella variabile d'ambiente opzionale `WINPENPACK_7ZIP` (percorso completo al tuo `7z.exe`, es. quello portabile di winPenPack).

Il `.gitignore` esclude `releases/`, tutti gli `.exe` compilati e i temporanei di build.



A differenza del tentativo precedente, qui **non serve nessuno script VBS esterno**: il motore X-Launcher gestisce il primo avvio in modo nativo tramite l'ini stesso:

1. `x-launcher.ini` ha `[Options] FirstRun=true`.
2. Al primo avvio di `X-Submarine.exe`, il motore esegue tutto quello che trova in `[FirstRunOperations]` — qui `RunFile=$Bin$\$AppName$\Init_Submarine.bat`, che scarica l'ultima release da GitHub, verifica il checksum se disponibile, estrae con 7-Zip e isola `Submarine.exe`.
3. Se `Init_Submarine.bat` **fallisce** (codice di uscita diverso da 0), il motore mostra un errore e **non** disattiva `FirstRun`: al prossimo avvio riprova.
4. Se ha successo, il motore stesso riscrive `x-launcher.ini` impostando `FirstRun=false`, così le esecuzioni successive saltano direttamente all'avvio di `Submarine.exe` (`[FileToRun]`).

> **7-Zip**: non incluso. Lo script lo cerca prima come installazione locale (`Program Files\7-Zip` o `(x86)`), poi come versione portabile in `winPenPack\Bin\7-Zip\7z.exe`.

## Variabili usate nell'ini

Ho corretto anche le macro di percorso, che nel tentativo precedente erano sbagliate (`$User$` non esiste nel motore reale):

- `$Bin$` → cartella `Bin` del tuo winPenPack
- `$Home$` → cartella `User` del tuo winPenPack (equivalente di quello che nel tentativo precedente chiamavo `$User$`)
- `$AppName$` → `Submarine` (definito in `[Setup]`)

## Cosa NON ho potuto fare

- Non posso compilare `X-Submarine.exe` da qui (serve AutoIt su Windows).
- Non posso generare un'icona `.ico` vera.
- Non ho copie di `X-Launcher.exe` o della cartella `_x-launcher` del tuo winPenPack esistente: quella inclusa qui è ricopiata identica dal pacchetto sorgente di X-Firefox che hai allegato, per coerenza — se il tuo `_x-launcher` è già aggiornato a una revisione diversa, usa quello che hai già invece di sovrascriverlo.
