# Standard di Naming per i Rilasci (Builds)

Per garantire la tracciabilità e l'organizzazione dei file binari, abbiamo stabilito un formato standard per ogni esportazione/build del progetto.

## 📂 Cartella di Destinazione

Tutte le build devono essere salvate nella cartella:
`builds/` (esclusa dal sistema di controllo versione Git).

## 🏷️ Formato del Nome

Il formato richiesto per ogni archivio della build è il seguente:

`TeamHarmony_[Stato]_[Versione]_[Data].zip`

### Elementi del nome:

1.  **TeamHarmony**: Prefisso fisso del team/progetto.
2.  **Stato**: La fase di sviluppo (es. `Alpha`, `Beta`, `Release`, `Hotfix`).
3.  **Versione**: Seguendo il versionamento semantico (es. `v0-1-0`). Usa i trattini `-` invece dei punti `.` per evitare problemi di estensione file su alcuni sistemi.
4.  **Data**: Formato `YYYY-MM-DD` (es. `2026-03-05`).

---

### ✅ Esempi Corretti:

- `TeamHarmony_Alpha_v0-1-0_2026-02-16.zip`
- `TeamHarmony_Beta_v0-2-5_2026-03-10.zip`
- `TeamHarmony_Release_v1-0-0_2026-04-01.zip`

### ❌ Esempi da Evitare:

- `build_finale.zip`
- `mio_gioco_v1.zip`
- `TeamHarmony_test.zip`

---

## 🛠️ Procedura di Export (Godot)

1. Aprire **Project > Export**.
2. Selezionare il preset desiderato (Windows, Mac, etc.).
3. Nel campo **Export Path**, selezionare la cartella `builds/`.
4. Nominare il file seguendo lo standard sopra descritto.
5. Assicurarsi di comprimere la cartella risultante in un file `.zip`.
