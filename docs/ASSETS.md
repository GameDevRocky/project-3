# Assets Manifest and Guidelines

Guidelines and directory structure for 3D models, 2D artwork, materials, and audio files used across Project 3.

---

## 1. Directory Structure

```
assets/
├── environment/     # Architectural modular pieces (walls, doors, floors, lights)
├── portraits/       # 2D portrait textures, 3D frame meshes, cloth cover models
├── props/           # Interactive objects (breaker box, light switches, notes)
├── audio/
│   ├── sfx/         # Switches, footsteps, creaks, door creaks, breaker thud
│   └── ambient/     # Low room tones, tense drone, paranormal whispers
└── materials/       # Shared materials and shader resources
```

---

## 2. Visual Scene Rules

When creating visual asset scenes:
1. **Visuals only:** Asset scenes should contain only visual nodes (`MeshInstance3D`, `Decal`, `Sprite3D`). Do NOT attach logic scripts or collision bodies directly into raw asset scenes.
2. **Standard root:** Node root should be a `Node3D` with the asset name.
3. **Named parts:** If a mesh contains animated or interactable subparts (e.g., a painting frame with a removable cloth cover `CoverSheet`, or a light fixture with `BulbMesh`), name them clearly in the node tree.
4. **Performance budget:** Target low-to-moderate polygon counts suitable for web export (Compatibility renderer). Keep real-time lights sparse.

---

## 3. Audio Manifest

| Event / Sound | Path | Bus | Notes |
|---|---|---|---|
| Light Switch Click | `assets/audio/sfx/switch_toggle.ogg` | SFX | Crisp physical toggle |
| Breaker Trip Heavy Thud | `assets/audio/sfx/breaker_trip.ogg` | SFX | Deep metallic mechanical clank |
| Ghost Footsteps Dark | `assets/audio/sfx/ghost_footsteps.ogg` | SFX | Heavy hurried footsteps on wood |
| Painting Warp / Enter | `assets/audio/sfx/painting_shift.ogg` | SFX | Straining canvas / subtle vocal flutter |
| Disturbance Object Drop | `assets/audio/sfx/prop_fall.ogg` | SFX | Wooden or ceramic crash |
| Room Tone Tense | `assets/audio/ambient/house_drone.ogg` | Ambience | Subtle low frequency hum |

---

## 4. Licenses and Credits

All imported assets must have permissible open licenses (CC0, CC-BY, MIT, etc.). Log source URLs and author attributions here before committing external asset files.
