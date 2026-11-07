# Respiration Sim — Spec

Godot 4.5, GDScript only, **TABS for indentation**, static typing everywhere, GL Compatibility, HTML5 export.
Viewport 1280x720 (`canvas_items` / `keep`). All UI built in code; the only scene is `res://scenes/main.tscn`.
Map area x 0..680 (map-local == screen), side panel x 680..1280.

## What it teaches
Breathing in: the diaphragm contracts and flattens, the ribs lift, the lungs expand and air is pulled in through
the nose and mouth → pharynx → larynx → trachea → bronchi → bronchioles → alveoli, where oxygen passes into the
blood. Breathing out: the diaphragm relaxes and domes up, the lungs shrink, and carbon dioxide leaves the blood
and goes back up and out. Labels follow page 3 of the Flying Colors "Respiratory System" task cards. No numbers.

## Art
`art/source/respiratory-system.svg` (583.133 x 555.854). Named groups used: `outline`, `Diaphram`, `RightLung`,
`LeftLung` (includes `bronchioles`), `tranchea-bronchi`, `oralk-nsal`, `Face-Bones`, `Lines`, `Boxes`, and the
invisible guide `airflow`. Rendered with Chromium at 2x into `art/layers/`: base, diaphragm, right_lung, left_lung,
airway, labels. Each layer is rendered with `Layer_1` hidden and only its own groups visible (hiding the whole
`<svg>` would also hide the filters the diaphragm's muscle stripes need).
Draw order: base < diaphragm < right lung < left lung < airway < gas dots / quiz puff < labels < BoxTargets.

## Breathing (Explore)
States OUT → INHALING (4.5 s at 1x) → IN (pause 0.8 s when playing) → EXHALING (5.0 s) → OUT (pause 1.2 s).
Speed slider 0.5x–2x. Breath amount b eases 0→1→0 (cosine).
- Lungs scale by 1 + 0.10 b about their hilum (cut-open lung: where the left bronchus enters; whole lung: its
  inner edge). Diaphragm scales (1 + 0.03 b, 1 − 0.13 b) about (327, 600), i.e. it flattens and its top moves
  down about as far as the lung bottoms. The chest widens (ribs move out): the base layer is drawn in 3 px rows,
  each widened about x = 327 by up to 5% × b, ramping from 0 at y 300 (neck) to full at y 430 and below
  (`layer_row_scale`). Label lines and boxes never move.
- `GasCloud`: 36 dots per breath, all at one speed (±3%), starting within 12% of the breath, so they move as a
  bunched cloud down the airway; per-dot sideways offset ±4.5 px plus a sine wobble. On the exhale, dots deeper in
  the lung start first so they all reach the bronchus together.
  Oxygen: in from 30 px outside the nostril (fading in), along the path to a random exit point inside the
  cut-open lung, then to the nearest of a few random bronchiole points while shrinking to 0 (0.7 s).
  Carbon dioxide: exact reverse, growing from 0 at a bronchiole point, then back along the path and out.
  Dots inside the lung follow the lung's transform (blended in along the path, AIRFLOW indices 76–89).
- The side panel and outlines follow the leading air: `region_at(front_distance())`. Regions begin at AIRFLOW
  indices 0, 28, 46, 59, 70, 89 (Nose & Mouth, Pharynx, Larynx, Trachea, Left Bronchus, Bronchioles).

## Quiz
Same engine as the digestion sim. Stations sit on the airflow path nearest each label pointer
(AIRFLOW indices 20, 40, 49, 63, 81, 138). A small puff of oxygen dots (`AirPuffToken`) travels; at the
Bronchioles it scatters into the bronchioles and shrinks away.
Helper groups (label on own box, any order, before moving INTO the station): Diaphragm before Nose & Mouth;
Right Bronchus before Left Bronchus; Right Lung + Left Lung before Bronchioles. Part 1 total = 10.
Part 2: 11 organ jobs onto their boxes (texts short enough for one line in the 49 px boxes).
