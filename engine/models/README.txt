engine/models/ — AI model weights directory
============================================

Place your trained model weight files here so the engine can find them.
The engine is currently running in PLACEHOLDER mode (a deterministic
chair-shaped mesh is returned regardless of the input image).

To use a real model
-------------------
1. Obtain or train a single-image-to-3D mesh model.
   Recommended open-source options (as of 2024):
     • One-2-3-45   https://github.com/One-2-3-45/One-2-3-45
     • TripoSR      https://github.com/VAST-AI-Research/TripoSR
     • GET3D        https://github.com/nv-tlabs/GET3D
     • Zero123      https://github.com/cvlab-columbia/zero123

2. Export or convert the weights to whichever format the model uses
   (e.g., .pth for PyTorch, .onnx for ONNX Runtime).

3. Copy the weight file(s) into THIS directory.
   Example layout after adding a TripoSR checkpoint:
       engine/
       ├── models/
       │   ├── README.txt              ← this file
       │   └── triposr_weights.ckpt    ← your weights

4. Update engine/mesh_generator.py:
   • Import the model loader from the model's Python package.
   • Load weights from the path below:
       MODELS_DIR = Path(__file__).parent / "models"
   • Call model.predict(image_path) in the generate() function.
   • Remove (or keep as fallback) the _placeholder_chair_mesh() call.

5. Install any required Python packages:
       pip install -r engine/requirements.txt

6. Test from the command line:
       engine\run_engine.bat  "C:\Photos\chair.jpg"  "C:\output"
   Or on a non-Windows system:
       python engine/engine.py --image photos/chair.jpg --output output/

Notes
-----
• All model files in this directory are gitignored by default (they are
  typically hundreds of MB to several GB in size).
• The plugin works fully offline — no internet connection is needed at
  runtime once weights are in place.
• Model accuracy from a SINGLE photo is inherently approximate; the
  generated mesh is a best-effort reconstruction, not photogrammetry.
