# Respiration Sim — Journey of a Breath

A simple, visual Godot 4.5 illustration of the human respiratory system (not a real simulation).
Air goes in through the nose and mouth, down the pharynx, larynx, trachea and left bronchus into the
bronchioles of the cut-open left lung, then back out. The lungs expand, the chest widens and the
diaphragm flattens and moves down as you breathe in; all return as you breathe out.

## Modes
- **Explore**: Breathe in, Breathe out, or Play to keep breathing (Pause lets the current breath finish).
  - Breathing in: bright green **oxygen** dots come in at the nose, wobble down the airway and scatter
    into the bronchioles, shrinking to nothing as they pass into the blood.
  - Breathing out: bright purple **carbon dioxide** dots grow out of the bronchioles and wobble back up
    and out of the nose.
  - The side panel explains the phase (diaphragm, ribs, lungs) and shows where the leading air is. It
    switches, and the map box is outlined, as the air crosses into each part of the airway, both ways.
- **Quiz part 1**: drag the next stop for the air onto the map (Nose & Mouth → Pharynx → Larynx →
  Trachea → Left Bronchus → Bronchioles). Other organs must be labelled on their own boxes first:
  the Diaphragm before the first stop, the Right Bronchus before the Left Bronchus, and both lungs
  (any order) before the Bronchioles. A right card at the wrong time is a reminder, not a mistake.
- **Quiz part 2**: drag each organ's job onto its label box.

## Controls
| Key | Action |
|-----|--------|
| Space | Play / Pause (Explore) |
| Right arrow / N | Next half-breath (Breathe in, then Breathe out) |
| R | Reset / restart quiz |
| M | Switch Explore / Quiz |
| F11 | Full screen on/off (also the "Full screen" button) |
| Tab, arrows, Enter | Move between and press buttons/cards/boxes |

## Project layout
- `scripts/engine/` — engine shared with the digestion sim (`SimSystem`, `SimToken`, UI, quiz).
  `main.gd` adds the breathing cycle used by Explore mode.
- `scripts/systems/respiratory_system.gd` — airflow path, stations, organ boxes, text, and how the
  lungs and diaphragm move (`layer_transform`).
- `scripts/systems/gas_cloud.gd` — the oxygen / carbon dioxide dots of each breath.
- `scripts/systems/air_puff_token.gd` — the puff of air that travels in quiz part 1.
- `art/layers/` — rendered from `art/source/respiratory-system.svg` in separate layers (body, diaphragm,
  each lung, airway, labels) so the lungs and diaphragm can move.

## Export
Project → Export → **Web** (needs Godot 4.5 export templates). Serve `exports/web/` from a web server.
