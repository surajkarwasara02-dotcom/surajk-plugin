# surajk plugin — Image → 3D SketchUp Extension

> **Convert a single furniture photo into an approximate 3D SketchUp model — fully offline on Windows.**

---

## Overview

`surajk plugin` is a **SketchUp Pro 2021** extension (Ruby API) that:

1. Opens a simple dialog inside SketchUp.
2. Lets you select a JPG or PNG photo of furniture.
3. Calls a **bundled local Python engine** to generate a 3D mesh (OBJ format).
4. Automatically imports the mesh into the active SketchUp model.
5. Saves the result as a `.skp` file — no internet required.

> ⚠ The output is an **approximate** model reconstructed from a single image.
> Accuracy depends entirely on the AI model weights you provide (see
> [Adding a real AI model](#adding-a-real-ai-model)).
> The plugin ships with a **deterministic placeholder mesh** (a chair shape)
> so you can test the full pipeline without any model weights.

---

## Repository layout

```
surajk-plugin/
├── surajk_plugin.rb            # SketchUp extension loader (root)
├── surajk_plugin/
│   ├── main.rb                 # Menu registration & orchestrator
│   ├── config.rb               # Centralised path / UI settings
│   ├── dialog.rb               # HtmlDialog logic & Ruby callbacks
│   ├── importer.rb             # OBJ → SketchUp geometry importer
│   └── html/
│       └── dialog.html         # Web UI (HTML/CSS/JS)
├── engine/
│   ├── engine.py               # Python entry-point (CLI)
│   ├── mesh_generator.py       # Mesh generation (stub + real model hook)
│   ├── requirements.txt        # Optional Python dependencies
│   ├── run_engine.bat          # Windows batch launcher
│   └── models/
│       └── README.txt          # Where to put AI weight files
├── output/                     # Generated OBJ / MTL / SKP files land here
├── .gitignore
└── README.md
```

---

## Requirements

| Component | Version |
|-----------|---------|
| SketchUp Pro | 2021 or later |
| Windows | 10 / 11 (64-bit) |
| Python | 3.8 or later (for the engine) |

The placeholder stub requires **only the Python standard library** — no `pip install` needed until you add a real AI model.

---

## Installation

### Step 1 — Copy the extension into SketchUp's Plugins folder

1. Find your SketchUp Plugins directory.  
   Default location:  
   ```
   C:\Users\<YourName>\AppData\Roaming\SketchUp\SketchUp 2021\SketchUp\Plugins\
   ```
2. Copy the following items from this repository into that folder:
   - `surajk_plugin.rb`
   - `surajk_plugin\` (entire directory, including `html\`)
   - `engine\` (entire directory)
   - `output\` (entire directory)

   Your Plugins folder should look like:
   ```
   Plugins\
   ├── surajk_plugin.rb
   ├── surajk_plugin\
   │   ├── config.rb
   │   ├── dialog.rb
   │   ├── importer.rb
   │   ├── main.rb
   │   └── html\
   │       └── dialog.html
   ├── engine\
   │   ├── engine.py
   │   ├── mesh_generator.py
   │   ├── requirements.txt
   │   ├── run_engine.bat
   │   └── models\
   │       └── README.txt
   └── output\
   ```

### Step 2 — Ensure Python 3.8+ is available

Option A — **System Python** (easiest):
```
python --version    # must be 3.8+
```
If not installed, download from <https://www.python.org/downloads/>.

Option B — **Bundled Python runtime** (fully portable):
1. Download the [Python embeddable package](https://www.python.org/downloads/windows/) for Windows (`python-3.x.x-embed-amd64.zip`).
2. Unzip it into `engine\python\` so that `engine\python\python.exe` exists.
3. The batch launcher checks this location first and uses it automatically.

### Step 3 — Launch SketchUp

Start SketchUp Pro 2021.  You will see a new menu item:

```
Plugins  →  surajk plugin: Image → 3D
```

---

## Usage

1. Click **Plugins → surajk plugin: Image → 3D**.
2. The plugin dialog opens.
3. Click **Browse…** and select a JPG or PNG furniture photo.
4. A thumbnail preview appears.
5. Click **Image → 3D**.
6. The status area shows progress:
   - *"Running AI engine…"*
   - *"OBJ generated. Importing into SketchUp…"*
   - *"Done! Model saved to: …"*
7. The 3D mesh appears in your SketchUp viewport and the `.skp` is saved
   next to the `.obj` in the `output\` folder.

---

## Testing the engine from the command line

You can run the Python engine independently (useful for debugging):

```bat
cd path\to\Plugins\engine
run_engine.bat "C:\Photos\chair.jpg" "C:\Users\Me\Desktop\output"
```

Expected console output:
```
[INFO] Using system Python (python).
[INFO] Launching engine...
[INFO]   Image  : "C:\Photos\chair.jpg"
[INFO]   Output : "C:\Users\Me\Desktop\output"
[INFO]  Processing image : C:\Photos\chair.jpg
[INFO]  Mesh generated   : 96 verts, 144 faces  (0.00s)
[OK]    OBJ written      : C:\Users\Me\Desktop\output\chair.obj
[OK] Engine finished successfully.
```

---

## Adding a real AI model

The engine ships with a **placeholder stub** that produces a fixed chair
mesh.  To use a real single-image-to-3D model:

1. Read `engine\models\README.txt` for a list of recommended open-source models.
2. Download the model weights and place them in `engine\models\`.
3. Edit `engine\mesh_generator.py`:
   - Import the model loader.
   - Load weights from `Path(__file__).parent / "models" / "<weight_file>"`.
   - Replace the `return _placeholder_chair_mesh()` line with your model's
     `predict(image_path)` call.
4. Install any required Python packages:
   ```
   pip install -r engine\requirements.txt
   ```
5. Test via the command line before using inside SketchUp.

---

## Accuracy note

Reconstructing a full 3D model from **a single photograph** is an inherently
ill-posed problem.  The output will:

- Capture the visible face of the furniture approximately.
- Miss occluded surfaces (back, underside, sides not in the photo).
- Require clean-up in SketchUp for production use.

For best results:
- Use a well-lit, uncluttered photo.
- Position the furniture at roughly a 45° angle so three faces are visible.
- Use high-quality AI model weights (see resources in `engine\models\README.txt`).

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Menu item missing | Confirm `surajk_plugin.rb` is in the Plugins folder and the extension is enabled in *Window → Extension Manager*. |
| *"Engine launcher not found"* | Verify `engine\run_engine.bat` exists relative to `surajk_plugin.rb`. |
| *"Python not found"* | Install Python 3.8+ or place it at `engine\python\python.exe`. |
| *"Engine failed or produced no output"* | Run the batch file manually from the command prompt to see Python error messages. |
| Import fails | Ensure SketchUp Pro 2021 OBJ importer is enabled in *Window → Extension Manager*. |
| Dialog does not open | Open the Ruby Console (*Window → Ruby Console*) and look for error messages. |

---

## Uninstalling

Delete `surajk_plugin.rb` and the `surajk_plugin\` folder from your Plugins
directory, then restart SketchUp.

---

## License

MIT — see individual source files for copyright notices.
