# Running Tests

We use the **GUT (Godot Unit Test)** framework for testing.

## Command Line Interface (CLI)

You can run all tests (Unit + Integration) from the terminal using the Godot binary.

### macOS

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

### Windows

Assuming `godot.exe` is in your PATH:

```powershell
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

If not in PATH, replace `godot` with the full path to your executable, e.g., `"C:\Program Files\Godot\Godot_v4.5.1-stable_win64.exe"`.

### Linux

Assuming `godot` is in your PATH:

```bash
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

## Running in Editor

1. Open the **GUT** panel at the bottom of the editor.
2. Click **Run All**.
