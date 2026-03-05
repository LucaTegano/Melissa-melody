---
description: Genera un nome standard per una nuova build
---

Questo workflow aiuta a generare il nome corretto per un file di build secondo lo standard aziendale.

### 📝 Formato Standard

`TeamHarmony_[Fase]_[Versione]_[Data]`

### 🚀 Generazione Manuale (Esempio)

Se stai creando una build oggi:

1. Scegli la fase: `Alpha`
2. Scegli la versione: `v0-1-1`
   // turbo
3. Esegui questo comando per copiare il nome suggerito (Mac):

```bash
echo "TeamHarmony_Alpha_v0-1-1_$(date +%F)" | pbcopy
```

### 📁 Destinazione

Assicurati di salvare il file esportato in:
`[Cartella Progetto]/builds/`
