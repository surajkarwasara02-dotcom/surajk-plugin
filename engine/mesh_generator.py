"""
engine/mesh_generator.py
Generates a deterministic placeholder 3D mesh that roughly resembles
a piece of furniture (a simple chair: seat + four legs + back-rest).

When real AI model weights are available in engine/models/, swap out
the generate() function body with actual inference code (e.g., calling
a depth-estimation network followed by Poisson surface reconstruction,
or loading an end-to-end image-to-mesh model such as One-2-3-45 or
GET3D).  The rest of the pipeline (OBJ writing, argument handling) stays
unchanged.

Usage:
    from mesh_generator import generate
    verts, faces = generate(image_path)
"""

from __future__ import annotations

import os
from pathlib import Path
from typing import List, Tuple

# ---------------------------------------------------------------------------
# Type aliases
# ---------------------------------------------------------------------------
Vertex = Tuple[float, float, float]
Face   = Tuple[int, int, int]       # 0-based vertex indices


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def generate(image_path: str) -> Tuple[List[Vertex], List[Face]]:
    """
    Return (vertices, faces) for a mesh derived from *image_path*.

    Currently this is a deterministic stub that always returns a
    chair-like box mesh regardless of the input image.  Replace the
    body of this function with real inference once model weights are
    available.

    Parameters
    ----------
    image_path : str
        Absolute path to the input image (JPG / PNG).

    Returns
    -------
    vertices : list of (x, y, z) tuples  — in metres
    faces    : list of (i, j, k) tuples  — 0-based, triangles
    """
    _validate_image(image_path)

    # ------------------------------------------------------------------
    # TODO: Replace the block below with real model inference.
    #
    # Example integration sketch (pseudo-code):
    #
    #   from your_model import ImageTo3DModel
    #   weights = Path(__file__).parent / 'models' / 'furniture_mesh.pth'
    #   model = ImageTo3DModel.load(weights)
    #   verts, faces = model.predict(image_path)
    #   return verts, faces
    # ------------------------------------------------------------------

    return _placeholder_chair_mesh()


# ---------------------------------------------------------------------------
# Placeholder geometry — a stylised chair (seat + legs + backrest)
# ---------------------------------------------------------------------------

def _placeholder_chair_mesh() -> Tuple[List[Vertex], List[Face]]:
    """
    Build a very simple chair-like mesh.

    Coordinate system:
        +X = right, +Y = depth, +Z = up
    All dimensions in metres.
    """
    verts: List[Vertex] = []
    faces: List[Face]   = []

    def add_box(
        x0: float, y0: float, z0: float,
        x1: float, y1: float, z1: float,
    ) -> None:
        """Append a box (12 triangles) to verts/faces."""
        base = len(verts)
        # 8 corners
        verts.extend([
            (x0, y0, z0), (x1, y0, z0), (x1, y1, z0), (x0, y1, z0),  # bottom
            (x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1),  # top
        ])
        # 6 faces → 12 triangles (all wound CCW from outside)
        face_quads = [
            (0, 1, 2, 3),  # bottom  -Z
            (4, 7, 6, 5),  # top     +Z
            (0, 4, 5, 1),  # front   -Y
            (2, 6, 7, 3),  # back    +Y
            (0, 3, 7, 4),  # left    -X
            (1, 5, 6, 2),  # right   +X
        ]
        for q in face_quads:
            a, b, c, d = (base + i for i in q)
            faces.append((a, b, c))
            faces.append((a, c, d))

    # Seat  (0.45 m high, 0.45 × 0.45 m square)
    add_box(0.00, 0.00, 0.42,  0.45, 0.45, 0.47)

    # Four legs (0.04 × 0.04 m cross-section, 0.42 m tall)
    margin = 0.03
    leg_w  = 0.04
    for lx, ly in [
        (margin,               margin),
        (0.45 - margin - leg_w, margin),
        (margin,               0.45 - margin - leg_w),
        (0.45 - margin - leg_w, 0.45 - margin - leg_w),
    ]:
        add_box(lx, ly, 0.00,  lx + leg_w, ly + leg_w, 0.42)

    # Back-rest (full width, 0.04 m thick, from seat to 0.90 m)
    add_box(0.00, 0.41, 0.47,  0.45, 0.45, 0.90)

    return verts, faces


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _validate_image(image_path: str) -> None:
    """Raise ValueError if the image path looks invalid."""
    p = Path(image_path)
    if not p.exists():
        raise FileNotFoundError(f"Image not found: {image_path}")
    if p.suffix.lower() not in {".jpg", ".jpeg", ".png"}:
        raise ValueError(
            f"Unsupported image format '{p.suffix}'.  Use JPG or PNG."
        )
