# Submarine Portable — struttura winPenPack

Pacchetto X-Launcher per **Submarine**, con download automatico dell'eseguibile al primo avvio (l'app non e' inclusa nell'archivio, viene scaricata dall'ultima release GitHub).

## Struttura delle cartelle

```
winPenPack/
├── XDrive/
│   ├── X-Submarine.ini     ← config X-Launcher (rinominata con prefisso X-)
│   └── X-Submarine.exe     ← NON incluso: copia di X-Launcher.exe rinominata (vedi LEGGIMI dentro la cartella)
├── Bin/
│   └── Submarine/
│       ├── CheckFirstRun.vbs   ← eseguito da X-Launcher prima di Submarine.exe
│       ├── Init_Submarine.bat  ← download/estrazione, lanciato da CheckFirstRun.vbs solo se Submarine.exe manca
│       └── Submarine.exe   ← NON incluso: viene creato qui al primo avvio
└── User/
    └── Submarine/
        ├── Profile/              ← redirect di USERPROFILE
        └── AppData/
            ├── Roaming/          ← redirect di APPDATA
            └── Local/            ← redirect di LOCALAPPDATA
```

`X-Submarine.exe` e `X-Submarine.ini` devono stare **nella stessa cartella** (`XDrive/`), fianco a fianco: X-Launcher legge la propria configurazione dal file `.ini` con lo stesso nome del proprio eseguibile (prefisso `X-` a parte).

> **7-Zip**: questo pacchetto non include 7-Zip. `Init_Submarine.bat` lo cerca da solo, in quest'ordine: prima un'installazione locale (`C:\Program Files\7-Zip\7z.exe` o `(x86)`), poi — solo se assente — la versione portabile in `winPenPack\Bin\7-Zip\7z.exe` (allo stesso livello di `Bin\Submarine`, se presente in un tuo pacchetto winPenPack). Se nessuna delle due viene trovata, lo script si ferma con un errore.

Le cartelle vuote contengono un file `.keep` solo per preservare la struttura nello zip: puoi cancellarlo una volta che ci sono file veri dentro.

## Come funziona il primo avvio

1. `X-Submarine.exe` legge `X-Submarine.ini` (in `XDrive/`) ed esegue `[RunBefore]`: lancia `CheckFirstRun.vbs` e attende che finisca.
2. `CheckFirstRun.vbs` controlla se `Bin\Submarine\Submarine.exe` esiste.
   - Se esiste, non fa nulla e X-Launcher prosegue con `[Run]`.
   - Se manca, lancia `Init_Submarine.bat` (finestra visibile) e aspetta che finisca.
3. `Init_Submarine.bat`:
   - Interroga la GitHub API per l'ultima release di `SinaXhpm/Submarine` (asset x64 o arm64, in base a `PROCESSOR_ARCHITECTURE`).
   - Scarica il setup NSIS, con un retry automatico se il primo tentativo fallisce.
   - Se la release pubblica un checksum (`.sha256` / `checksums.txt`), lo verifica con `certutil` prima di procedere; se non e' disponibile, avvisa e continua.
   - Cerca 7-Zip: prima un'installazione locale (`Program Files\7-Zip` o `(x86)`), poi la versione portabile in `Bin\7-Zip\7z.exe` (risalendo da `Bin\Submarine`) — vedi nota su 7-Zip sopra.
   - Estrae il setup NSIS con 7-Zip, isola `Submarine.exe` dalla struttura dell'installer e pulisce i residui (`$_OUTDIR`, `$PLUGINSDIR`, `$TEMP`).
   - Verifica che `Submarine.exe` sia effettivamente presente al termine.
4. X-Launcher esegue `[Run]`: avvia `Bin\Submarine\Submarine.exe`.

## Note

- `Init_Submarine.bat` ha mantenuto il nome originale (senza versione/timestamp nel nome file) perche' e' richiamato per nome fisso da `CheckFirstRun.vbs`; la versione e la data di rilascio sono nell'header del file.
- Se in futuro `SinaXhpm/Submarine` pubblica anche build arm64 con un pattern di nome diverso da quello atteso (`arm64-setup.exe`), va aggiornato `ARCH_PATTERN` in `Init_Submarine.bat`.
