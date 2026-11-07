# Respiration Sim — Claude Code Project Context

Simple visual (not a real simulation) Godot 4.5 illustration of breathing. Explore mode is a breathing
cycle: lungs expand and the diaphragm flattens on the inhale; green oxygen dots follow the airflow path into
the bronchioles and shrink away; purple carbon dioxide dots do the reverse on the exhale. Quiz part 1
(order of the airway; other organs labelled on their own boxes first) and part 2 (match organ jobs).
HTML5 export; mouse, touch, keyboard; Full screen button + F11.

## Standards
- Godot 4.5, GDScript, TABS only, static typing, GL Compatibility; UI built in code; one scene.
- Engine (scripts/engine) only uses SimSystem/SimToken; system data in scripts/systems.
- Geometry measured from art/source/respiratory-system.svg ("airflow", "bronchioles", label lines/boxes);
  layers in art/layers rendered from it at 2x (1360 px wide), drawn at SVG_SCALE 1.1661, offset (0, 36).
  If the art changes, re-measure and re-render.
- Sister projects: SFMiner/dogestive-sim (same engine), SFMiner/circulation-sim (same UI patterns).

See docs/SPEC.md and README.md.
