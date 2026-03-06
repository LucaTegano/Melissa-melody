# Mel's Melody (Oliva) — Project Context

## Panoramica

**Mel's Melody** è un gioco 2D action-platformer sviluppato in **Godot 4.5** con **GDScript**, dal team **TeamHarmony**. Il giocatore controlla "Mel", un personaggio che può correre, saltare, eseguire dash e attaccare nemici.

- **Repository**: [LucaTegano/Melissa-melody](https://github.com/LucaTegano/Melissa-melody)
- **Branch principale**: `main`
  Push su `main` ** sempre**.
- **Renderer**: Forward Plus

---

## Struttura del Progetto

```
.
├── src/                    # Codice sorgente GDScript + scene
│   ├── core/               # Sistemi globali (Autoload)
│   │   └── GameManager.gd  # Autoload — salvataggio/caricamento partita
│   ├── entities/           # Entità di gioco (scena + script insieme)
│   │   ├── player/         # player.gd + player.tscn (CharacterBody2D)
│   │   └── enemy/          # enemy.gd + enemy.tscn (CharacterBody2D)
│   ├── levels/             # Scene dei livelli
│   │   └── test_level.tscn
│   ├── ui/                 # Interfaccia utente
│   │   └── main_menu/      # main_menu.gd + main_menu.tscn (Control)
│   └── shared/             # Componenti riutilizzabili
│       └── save_area/      # save_area.gd + save_area.tscn (Area2D)
├── assets/                 # Risorse statiche
│   ├── audio/              # default_bus_layout.tres
│   ├── fonts/              # PixelOperator8 (Regular + Bold)
│   ├── sprites/            # Spritesheet (attualmente vuota)
│   └── textures/           # Texture organizzate per categoria
│       ├── player/
│       ├── enemy/
│       └── ui/             # icon.svg (icona progetto)
├── tests/                  # Test (framework GUT)
│   ├── unit/               # test_player.gd
│   └── integration/        # test_player_integration.gd
├── addons/                 # Plugin Godot
│   └── gut/                # Godot Unit Test framework
├── builds/                 # Esportazioni / build (escluse da Git)
├── doc/                    # Documentazione
│   ├── BuildStandards.md   # Standard di naming per le build
│   ├── Commands.md         # Comandi CLI per i test
│   └── AI/PUSH.md          # Regole di push
├── .agents/                # Configurazione agenti AI
│   ├── workflows/          # Workflow (es. build_naming)
│   └── skills/             # Skill installate (godot-gdscript-patterns)
├── project.godot           # Configurazione progetto Godot
└── .gitignore              # Ignora .godot/, builds/, etc.
```

---

## Architettura e Sistemi Chiave

### Autoload

| Nome          | Percorso                        | Responsabilità                                               |
| ------------- | ------------------------------- | ------------------------------------------------------------ |
| `GameManager` | `res://src/core/GameManager.gd` | Salvataggio/caricamento partita, stato globale del giocatore |

### Entità

- **Player** (`CharacterBody2D`): Movimento (corsa, salto con _jump cut_), dash con cooldown, attacco melee con _hit freeze_ e knockback bidirezionale. Ripristina la posizione dal `GameManager` al `_ready()`.
- **Enemy** (`CharacterBody2D`): Patrol AI semplice (si inverte quando colpisce un muro). Supporta knockback tramite `take_damage(source_position, force)`.

### Componenti Condivisi

- **SaveArea** (`Area2D`): Zona di salvataggio. Quando il player entra mostra un prompt; premendo `ui_accept` il gioco viene salvato (JSON in `user://savegame.save`).

### UI

- **MainMenu** (`Control`): Due pulsanti — "Nuova Partita" (carica `test_level.tscn`) e "Carica Partita" (invoca `GameManager.load_game()`).

---

## Input Map

| Azione       | Tasto                     | Note                                  |
| ------------ | ------------------------- | ------------------------------------- |
| `move_left`  | `A` / `←`                 |                                       |
| `move_right` | `D` / `→`                 |                                       |
| `move_up`    | `W` / `↑`                 | **Saltare** / Scala (futuro)          |
| `move_down`  | `S` / `↓`                 | **Scendere veloce** / Scendi (futuro) |
| `jump`       | `Spazio` / `W`            |                                       |
| `dash`       | `Shift` (destro/sinistro) |                                       |
| `attack`     | `Click sinistro` (mouse)  |                                       |
| `interact`   | `W` / `↑` / `E`           | Interazione (es. salvataggio)         |

---

## Comandi Utili

### Eseguire i test (GUT)

```bash
# macOS
/Applications/Godot.app/Contents/MacOS/Godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit

# Windows (con godot.exe nel PATH)
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

### Generare nome build standard

Formato: `TeamHarmony_[Fase]_[Versione]_[Data].zip`

```bash
echo "TeamHarmony_Alpha_v0-1-0_$(date +%F)" | pbcopy
```

Le build vanno salvate in `builds/` (esclusa da Git).

---

## Convenzioni di Codice

- **Linguaggio**: GDScript (Godot 4.5)
- **Struttura file**: Ogni entità ha la propria cartella con `.gd` + `.tscn` insieme
- **Autoload**: Registrati in `project.godot` nella sezione `[autoload]`
- **Segnali**: Collegati via codice nel `_ready()` (non dall'editor)
- **Gruppi**: I nemici appartengono al gruppo `"enemies"`
- **Percorsi**: Usare sempre `res://src/...` per i percorsi interni
- **Commenti**: In italiano
- **Charset**: UTF-8 (vedi `.editorconfig`)
- **Test**: I test unit vanno in `tests/unit/`, quelli di integrazione in `tests/integration/`; entrambi estendono `GutTest`

---

## Regole di Git e Rilascio

1. \*\* Push su `main` sempre.
2. **Build naming**: `TeamHarmony_[Stato]_[Versione]_[Data].zip` (es. `TeamHarmony_Alpha_v0-1-0_2026-03-05.zip`)
3. **Versioning**: Semantico con trattini (`v0-1-0` anziché `v0.1.0`) per compatibilità nomi file.
4. **`builds/`** è nella `.gitignore` — non committare mai i binari.

---

## Note per l'AI

- La **skill `godot-gdscript-patterns`** è installata in `.agents/skills/` — consultarla per pattern GDScript avanzati (state machine, segnali, ottimizzazioni).
- Il workflow **`/build_naming`** genera automaticamente il nome corretto per una nuova build.
- I test attuali (`test_player.gd`) fanno riferimento a costanti (`SPEED`, `JUMP_VELOCITY`, `DASH_DISTANCE`, etc.) che **non corrispondono** ai nomi attuali nel `player.gd` (che usa `run_speed`, `jump_force`, etc.). Questi test **necessitano di aggiornamento**.
- Il file di salvataggio è `user://savegame.save` in formato JSON.
