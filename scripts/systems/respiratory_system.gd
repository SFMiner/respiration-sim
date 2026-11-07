class_name RespiratorySystem
extends SimSystem
## The respiratory system: air goes in through the nose and mouth, down the airways and into the
## bronchioles of the cut-open (left) lung, then back out.
## Art: art/source/respiratory-system.svg (583.133 x 555.854) scaled by SVG_SCALE to the 680 px map
## width and moved down SVG_OFFSET. Rendered into separate layers (art/layers/*.png) so the lungs
## and diaphragm can move. The airflow path, pointer dots and bronchiole points were measured from
## the SVG ("airflow", "bronchioles") in Chromium. If the art changes, re-measure and re-render.

const SVG_SCALE: float = 1.1661
const SVG_OFFSET: Vector2 = Vector2(0.0, 36.0)

# Station indices (quiz part 1 order and the explore "path of air")
const NOSE_MOUTH: int = 0
const PHARYNX: int = 1
const LARYNX: int = 2
const TRACHEA: int = 3
const LEFT_BRONCHUS: int = 4
const BRONCHIOLES: int = 5

## Index into AIRFLOW where each station's region begins (air crosses into it there).
const REGION_START: Array[int] = [0, 28, 46, 59, 70, 89]
## Index into AIRFLOW where the quiz puff stops for each station (nearest the label pointer).
const STATION_INDEX: Array[int] = [20, 40, 49, 63, 81, 138]

## Breathing. The cut-open lung grows from where the left bronchus enters it, the whole lung from
## its inner edge, so neither pulls away from the trachea. The diaphragm flattens and moves down.
const LUNG_GROW: float = 0.10
const LEFT_LUNG_PIVOT: Vector2 = Vector2(338.0, 400.0)
const RIGHT_LUNG_PIVOT: Vector2 = Vector2(305.0, 405.0)
const DIAPHRAGM_PIVOT: Vector2 = Vector2(327.0, 600.0)
const DIAPHRAGM_FLATTEN: float = 0.13
const DIAPHRAGM_WIDEN: float = 0.03
## The chest widens as the ribs move out: the body outline widens about its centre line,
## not at all at the neck, fully from the chest down (smooth in between).
const CHEST_CENTRE_X: float = 327.0
const CHEST_WIDEN: float = 0.05
const CHEST_FROM_Y: float = 300.0
const CHEST_FULL_Y: float = 430.0
## Along the airflow path, gas dots start moving with the cut-open lung between these indices.
const LUNG_BLEND_FROM: int = 76
const LUNG_BLEND_TO: int = 89

## The SVG "airflow" path sampled every 6 map px, from the nostril into the left lung.
const AIRFLOW: Array[Vector2] = [
		Vector2(209.2, 162.7), Vector2(213.8, 159.1), Vector2(217.9, 154.6), Vector2(221.8, 150.1), Vector2(226.2, 146.1), Vector2(231.4, 143),
		Vector2(236.8, 140.4), Vector2(242.3, 137.9), Vector2(247.8, 135.8), Vector2(253.5, 133.8), Vector2(259.3, 132.3), Vector2(265.3, 131.9),
		Vector2(271.2, 132.6), Vector2(276.4, 135.6), Vector2(278.5, 141), Vector2(276.5, 146.5), Vector2(271.7, 150), Vector2(265.8, 150.8),
		Vector2(260, 149.2), Vector2(257.1, 144.1), Vector2(260.6, 139.9), Vector2(266.4, 138.5), Vector2(272.4, 137.9), Vector2(278.4, 137.7),
		Vector2(284.4, 137.9), Vector2(289.9, 139.7), Vector2(294.1, 144), Vector2(298.1, 148.5), Vector2(302.6, 152.4), Vector2(307.7, 155.6),
		Vector2(312.6, 159), Vector2(317.4, 162.6), Vector2(322, 166.5), Vector2(325.9, 171), Vector2(328.3, 176.5), Vector2(329.6, 182.3),
		Vector2(330.2, 188.3), Vector2(330.3, 194.3), Vector2(329.8, 200.3), Vector2(328.8, 206.2), Vector2(327.5, 212), Vector2(325.6, 217.7),
		Vector2(323, 223.2), Vector2(320.1, 228.4), Vector2(318.2, 234.1), Vector2(316.7, 239.9), Vector2(315.3, 245.7), Vector2(314, 251.6),
		Vector2(312.8, 257.5), Vector2(311.7, 263.4), Vector2(310.9, 269.3), Vector2(310.6, 275.3), Vector2(311, 281.3), Vector2(312, 287.2),
		Vector2(313.7, 292.9), Vector2(315.7, 298.6), Vector2(317.8, 304.2), Vector2(319.7, 309.9), Vector2(321.1, 315.7), Vector2(322, 321.7),
		Vector2(322.3, 327.7), Vector2(322.2, 333.7), Vector2(322, 339.6), Vector2(321.6, 345.6), Vector2(321.3, 351.6), Vector2(321.1, 357.6),
		Vector2(321.1, 363.6), Vector2(322.2, 369.5), Vector2(324.1, 375.2), Vector2(325.8, 380.9), Vector2(326.6, 386.9), Vector2(323.4, 391.6),
		Vector2(318, 394.2), Vector2(312.4, 396.5), Vector2(307, 399), Vector2(307.5, 400), Vector2(313.1, 397.8), Vector2(318.8, 396.3),
		Vector2(324.8, 396.2), Vector2(330.1, 399), Vector2(335.2, 402.2), Vector2(340.3, 405.4), Vector2(345.4, 408.5), Vector2(350.6, 411.4),
		Vector2(356, 414.1), Vector2(361.5, 416.4), Vector2(367.4, 417.7), Vector2(372.3, 415.3), Vector2(371.8, 409.3), Vector2(370, 403.6),
		Vector2(367.7, 398.1), Vector2(365.1, 392.7), Vector2(362, 387.6), Vector2(357.3, 383.8), Vector2(352.6, 380.1), Vector2(357.2, 380.4),
		Vector2(358.7, 376.3), Vector2(358.4, 370.3), Vector2(358.2, 364.3), Vector2(358, 358.3), Vector2(358, 352.3), Vector2(361.7, 348.4),
		Vector2(367.6, 348.2), Vector2(373.4, 349.6), Vector2(378.2, 353.1), Vector2(380.8, 358.5), Vector2(383.3, 364), Vector2(385.7, 369.4),
		Vector2(388.1, 374.9), Vector2(390.5, 380.4), Vector2(392.9, 386), Vector2(395.3, 391.5), Vector2(397.6, 397), Vector2(399.9, 402.5),
		Vector2(401.3, 408.3), Vector2(401.8, 414.3), Vector2(402.1, 420.3), Vector2(402.4, 426.3), Vector2(402.6, 432.3), Vector2(402.7, 438.3),
		Vector2(402.8, 444.3), Vector2(402.8, 450.3), Vector2(402.5, 456.3), Vector2(400.4, 461.9), Vector2(396.6, 466.5), Vector2(391.9, 470.2),
		Vector2(386.6, 473), Vector2(381.1, 475.3), Vector2(375.3, 477), Vector2(369.4, 478.1), Vector2(363.4, 478.6), Vector2(357.5, 478.2),
		Vector2(352.1, 475.7), Vector2(353.9, 470.4), Vector2(358, 466), Vector2(362.4, 461.9), Vector2(366.6, 457.7), Vector2(370.2, 452.9),
		Vector2(370.7, 449.6),
]

## Points inside the SVG "bronchioles" shapes (cut-open lung, breathed-out position).
const BRONCHIOLE_POINTS: Array[Vector2] = [
		Vector2(369, 333.5), Vector2(369, 336.3), Vector2(369, 337.7), Vector2(367.6, 339.1), Vector2(367.6, 340.5), Vector2(359.3, 341.9),
		Vector2(371.8, 341.9), Vector2(367.6, 343.3), Vector2(362.1, 344.7), Vector2(370.4, 344.7), Vector2(367.6, 346.1), Vector2(362.1, 347.5),
		Vector2(380.2, 347.5), Vector2(364.8, 348.9), Vector2(360.7, 350.3), Vector2(366.2, 350.3), Vector2(364.8, 351.7), Vector2(362.1, 353.1),
		Vector2(376, 353.1), Vector2(363.4, 354.5), Vector2(377.4, 354.5), Vector2(364.8, 355.9), Vector2(380.2, 355.9), Vector2(355.1, 357.3),
		Vector2(376, 357.3), Vector2(385.8, 357.3), Vector2(356.5, 358.7), Vector2(367.6, 358.7), Vector2(381.6, 358.7), Vector2(357.9, 360.1),
		Vector2(367.6, 360.1), Vector2(381.6, 360.1), Vector2(359.3, 361.5), Vector2(367.6, 361.5), Vector2(381.6, 361.5), Vector2(362.1, 362.9),
		Vector2(367.6, 362.9), Vector2(378.8, 362.9), Vector2(387.2, 362.9), Vector2(367.6, 364.3), Vector2(378.8, 364.3), Vector2(387.2, 364.3),
		Vector2(369, 365.7), Vector2(384.4, 365.7), Vector2(367.6, 367.1), Vector2(380.2, 367.1), Vector2(366.2, 368.5), Vector2(378.8, 368.5),
		Vector2(366.2, 369.9), Vector2(377.4, 369.9), Vector2(385.8, 369.9), Vector2(370.4, 371.3), Vector2(384.4, 371.3), Vector2(370.4, 372.7),
		Vector2(384.4, 372.7), Vector2(370.4, 374.1), Vector2(383, 374.1), Vector2(369, 375.5), Vector2(381.6, 375.5), Vector2(395.6, 375.5),
		Vector2(370.4, 376.9), Vector2(381.6, 376.9), Vector2(395.6, 376.9), Vector2(366.2, 378.3), Vector2(376, 378.3), Vector2(381.6, 378.3),
		Vector2(395.6, 378.3), Vector2(356.5, 379.7), Vector2(376, 379.7), Vector2(381.6, 379.7), Vector2(394.2, 379.7), Vector2(359.3, 381.1),
		Vector2(376, 381.1), Vector2(388.6, 381.1), Vector2(356.5, 382.5), Vector2(367.6, 382.5), Vector2(377.4, 382.5), Vector2(391.4, 382.5),
		Vector2(362.1, 383.9), Vector2(374.6, 383.9), Vector2(390, 383.9), Vector2(362.1, 385.3), Vector2(369, 385.3), Vector2(377.4, 385.3),
		Vector2(362.1, 386.7), Vector2(367.6, 386.7), Vector2(376, 386.7), Vector2(364.8, 388.1), Vector2(370.4, 388.1), Vector2(377.4, 388.1),
		Vector2(364.8, 389.5), Vector2(370.4, 389.5), Vector2(391.4, 389.5), Vector2(367.6, 390.9), Vector2(374.6, 390.9), Vector2(401.2, 390.9),
		Vector2(371.8, 392.3), Vector2(391.4, 392.3), Vector2(370.4, 393.7), Vector2(390, 393.7), Vector2(395.6, 393.7), Vector2(401.2, 393.7),
		Vector2(406.8, 393.7), Vector2(373.2, 395.1), Vector2(391.4, 395.1), Vector2(373.2, 396.5), Vector2(370.4, 397.9), Vector2(387.2, 397.9),
		Vector2(373.2, 399.3), Vector2(387.2, 399.3), Vector2(383, 400.7), Vector2(371.8, 402.1), Vector2(383, 402.1), Vector2(388.6, 402.1),
		Vector2(370.4, 403.5), Vector2(378.8, 403.5), Vector2(377.4, 404.9), Vector2(398.4, 411.9), Vector2(404, 411.9), Vector2(399.8, 413.3),
		Vector2(397, 414.7), Vector2(395.6, 416.1), Vector2(390, 418.9), Vector2(390, 420.3), Vector2(378.8, 423.1), Vector2(384.4, 423.1),
		Vector2(390, 423.1), Vector2(408.2, 423.1), Vector2(391.4, 424.5), Vector2(399.8, 424.5), Vector2(405.4, 424.5), Vector2(380.2, 425.9),
		Vector2(392.8, 425.9), Vector2(398.4, 425.9), Vector2(404, 425.9), Vector2(381.6, 427.3), Vector2(378.8, 428.7), Vector2(395.6, 428.7),
		Vector2(380.2, 430.1), Vector2(397, 430.1), Vector2(383, 431.5), Vector2(399.8, 431.5), Vector2(411, 431.5), Vector2(384.4, 432.9),
		Vector2(398.4, 432.9), Vector2(404, 432.9), Vector2(409.6, 432.9), Vector2(384.4, 434.3), Vector2(399.8, 434.3), Vector2(405.4, 434.3),
		Vector2(383, 435.7), Vector2(394.2, 435.7), Vector2(401.2, 435.7), Vector2(412.4, 435.7), Vector2(387.2, 437.1), Vector2(399.8, 437.1),
		Vector2(413.8, 437.1), Vector2(387.2, 438.5), Vector2(395.6, 438.5), Vector2(413.8, 438.5), Vector2(387.2, 439.9), Vector2(395.6, 439.9),
		Vector2(404, 439.9), Vector2(366.2, 441.3), Vector2(388.6, 441.3), Vector2(401.2, 441.3), Vector2(363.4, 442.7), Vector2(384.4, 442.7),
		Vector2(391.4, 442.7), Vector2(401.2, 442.7), Vector2(406.8, 442.7), Vector2(370.4, 444.1), Vector2(390, 444.1), Vector2(399.8, 444.1),
		Vector2(408.2, 444.1), Vector2(370.4, 445.5), Vector2(388.6, 445.5), Vector2(404, 445.5), Vector2(411, 445.5), Vector2(371.8, 446.9),
		Vector2(390, 446.9), Vector2(405.4, 446.9), Vector2(364.8, 448.3), Vector2(385.8, 448.3), Vector2(398.4, 448.3), Vector2(364.8, 449.7),
		Vector2(371.8, 449.7), Vector2(390, 449.7), Vector2(363.4, 451.1), Vector2(371.8, 451.1), Vector2(388.6, 451.1), Vector2(362.1, 452.5),
		Vector2(369, 452.5), Vector2(387.2, 452.5), Vector2(404, 452.5), Vector2(363.4, 453.9), Vector2(370.4, 453.9), Vector2(387.2, 453.9),
		Vector2(392.8, 453.9), Vector2(362.1, 455.3), Vector2(370.4, 455.3), Vector2(378.8, 455.3), Vector2(392.8, 455.3), Vector2(405.4, 455.3),
		Vector2(369, 456.7), Vector2(378.8, 456.7), Vector2(392.8, 456.7), Vector2(404, 456.7), Vector2(362.1, 458.1), Vector2(376, 458.1),
		Vector2(388.6, 458.1), Vector2(405.4, 458.1), Vector2(363.4, 459.5), Vector2(378.8, 459.5), Vector2(388.6, 459.5), Vector2(398.4, 459.5),
		Vector2(360.7, 460.9), Vector2(371.8, 460.9), Vector2(383, 460.9), Vector2(397, 460.9), Vector2(406.8, 460.9), Vector2(360.7, 462.3),
		Vector2(373.2, 462.3), Vector2(384.4, 462.3), Vector2(399.8, 462.3), Vector2(355.1, 463.7), Vector2(362.1, 463.7), Vector2(378.8, 463.7),
		Vector2(387.2, 463.7), Vector2(401.2, 463.7), Vector2(356.5, 465.1), Vector2(362.1, 465.1), Vector2(374.6, 465.1), Vector2(388.6, 465.1),
		Vector2(353.7, 466.5), Vector2(360.7, 466.5), Vector2(371.8, 466.5), Vector2(380.2, 466.5), Vector2(392.8, 466.5), Vector2(352.3, 467.9),
		Vector2(363.4, 467.9), Vector2(374.6, 467.9), Vector2(387.2, 467.9), Vector2(392.8, 467.9), Vector2(349.5, 469.3), Vector2(370.4, 469.3),
		Vector2(376, 469.3), Vector2(388.6, 469.3), Vector2(395.6, 469.3), Vector2(348.1, 470.7), Vector2(362.1, 470.7), Vector2(374.6, 470.7),
		Vector2(388.6, 470.7), Vector2(397, 470.7), Vector2(346.7, 472.1), Vector2(362.1, 472.1), Vector2(374.6, 472.1), Vector2(387.2, 472.1),
		Vector2(397, 472.1), Vector2(402.6, 472.1), Vector2(359.3, 473.5), Vector2(370.4, 473.5), Vector2(378.8, 473.5), Vector2(388.6, 473.5),
		Vector2(402.6, 473.5), Vector2(357.9, 474.9), Vector2(364.8, 474.9), Vector2(381.6, 474.9), Vector2(398.4, 474.9), Vector2(355.1, 476.3),
		Vector2(363.4, 476.3), Vector2(378.8, 476.3), Vector2(399.8, 476.3), Vector2(355.1, 477.7), Vector2(364.8, 477.7), Vector2(381.6, 477.7),
		Vector2(342.5, 479.1), Vector2(355.1, 479.1), Vector2(366.2, 479.1), Vector2(401.2, 479.1), Vector2(353.7, 480.5), Vector2(366.2, 480.5),
		Vector2(384.4, 480.5), Vector2(366.2, 481.8), Vector2(383, 481.8), Vector2(355.1, 483.2), Vector2(380.2, 483.2), Vector2(385.8, 483.2),
		Vector2(367.6, 484.6), Vector2(385.8, 484.6), Vector2(369, 486), Vector2(367.6, 487.4), Vector2(390, 487.4), Vector2(391.4, 488.8),
		Vector2(392.8, 490.2), Vector2(395.6, 491.6), Vector2(378.8, 494.4),
]

var _cum: PackedFloat32Array = PackedFloat32Array()


func _init() -> void:
	title = "Journey of a Breath"
	traveller_name = "the air"
	start_label = "Ready to breathe"
	is_loop = false
	has_match_quiz = true
	min_travel_time = 0.6
	max_travel_time = 4.0
	_build_cumulative()
	_build_layers()
	_build_organs()
	_build_stations()
	_build_segments()


func _build_layers() -> void:
	layers = [
		{"path": "res://art/layers/base.png", "rect": Rect2(131.5, 36, 396.5, 616.5), "motion": "chest", "above_gas": false, "rows": true},
		{"path": "res://art/layers/diaphragm.png", "rect": Rect2(219, 484.5, 217, 131.5), "motion": "diaphragm", "above_gas": false},
		{"path": "res://art/layers/right_lung.png", "rect": Rect2(206.5, 310.5, 109.5, 212), "motion": "right_lung", "above_gas": false},
		{"path": "res://art/layers/left_lung.png", "rect": Rect2(329.5, 306.5, 109, 211), "motion": "left_lung", "above_gas": false},
		{"path": "res://art/layers/airway.png", "rect": Rect2(202, 72.5, 178.5, 372), "motion": "static", "above_gas": false},
		{"path": "res://art/layers/labels.png", "rect": Rect2(0, 85.5, 680, 599), "motion": "static", "above_gas": true},
	]


func layer_transform(motion: String, breath: float) -> Transform2D:
	match motion:
		"left_lung":
			return _scale_about(LEFT_LUNG_PIVOT, Vector2.ONE * (1.0 + LUNG_GROW * breath))
		"right_lung":
			return _scale_about(RIGHT_LUNG_PIVOT, Vector2.ONE * (1.0 + LUNG_GROW * breath))
		"diaphragm":
			return _scale_about(DIAPHRAGM_PIVOT, Vector2(1.0 + DIAPHRAGM_WIDEN * breath, 1.0 - DIAPHRAGM_FLATTEN * breath))
	return Transform2D.IDENTITY


func layer_row_scale(motion: String, breath: float, y: float) -> Vector2:
	if motion != "chest":
		return Vector2(0.0, 1.0)
	var amount: float = smoothstep(CHEST_FROM_Y, CHEST_FULL_Y, y)
	return Vector2(CHEST_CENTRE_X, 1.0 + CHEST_WIDEN * breath * amount)


func _scale_about(pivot: Vector2, s: Vector2) -> Transform2D:
	return Transform2D(0.0, s, 0.0, pivot - pivot * s)


func _build_organs() -> void:
	organs = {
		"nasal": {
			"name": "Nasal Cavity", "box": Rect2(2.1, 87.8, 183.2, 49.2),
			"function": "Cleans and warms the air",
			"hint": "",
		},
		"oral": {
			"name": "Oral Cavity", "box": Rect2(1.7, 165.6, 183.2, 49.2),
			"function": "A second way for air in or out",
			"hint": "",
		},
		"pharynx": {
			"name": "Pharynx", "box": Rect2(404.1, 136.4, 183.2, 49.2),
			"function": "Throat for both air and food",
			"hint": "",
		},
		"larynx": {
			"name": "Larynx", "box": Rect2(40.2, 235.6, 183.2, 49.2),
			"function": "Voice box: makes sound",
			"hint": "",
		},
		"trachea": {
			"name": "Trachea", "box": Rect2(415.4, 210.4, 183.2, 49.2),
			"function": "Windpipe: the largest airway",
			"hint": "",
		},
		"right_bronchus": {
			"name": "Right Bronchus", "box": Rect2(51.9, 317.2, 132, 67.2),
			"function": "Carries air into the right lung",
			"hint": "The trachea splits in two. The right bronchus carries air into the right lung, hidden inside it in this picture.",
		},
		"left_bronchus": {
			"name": "Left Bronchus", "box": Rect2(495, 305.5, 183.2, 49.2),
			"function": "Carries air into the left lung",
			"hint": "",
		},
		"bronchioles": {
			"name": "Bronchioles", "box": Rect2(462.6, 387.4, 152.6, 49.2),
			"function": "Tiny airways to air sacs",
			"hint": "",
		},
		"left_lung": {
			"name": "Left Lung", "box": Rect2(489.2, 523.4, 132, 67.2),
			"function": "Smaller, to leave room for the heart",
			"hint": "The left lung is a little smaller, to make room for the heart. Here it is cut open to show the bronchioles.",
		},
		"right_lung": {
			"name": "Right Lung", "box": Rect2(52.9, 581.6, 132, 67.2),
			"function": "Bigger lung, with 3 lobes",
			"hint": "The right lung is the bigger one, with 3 lobes. Right means the body's own right, so it is on the left of the picture.",
		},
		"diaphragm": {
			"name": "Diaphragm", "box": Rect2(237.6, 615.2, 166.5, 67.2),
			"function": "Muscle that pulls down to pull air in",
			"hint": "The diaphragm is the muscle under the lungs. When it contracts and pulls down, air rushes in.",
		},
	}
	organ_order = ["nasal", "oral", "pharynx", "larynx", "trachea", "right_bronchus",
		"left_bronchus", "bronchioles", "left_lung", "right_lung", "diaphragm"]
	quiz_distractors = []
	quiz_helper_groups = [
		{
			"before": NOSE_MOUTH, "organs": ["diaphragm"],
			"prompt": "First, label the muscle that makes you breathe in. Drag it onto its own box!",
		},
		{
			"before": LEFT_BRONCHUS, "organs": ["right_bronchus"],
			"prompt": "The trachea splits in two! First label the branch that goes into the right lung.",
		},
		{
			"before": BRONCHIOLES, "organs": ["right_lung", "left_lung"],
			"prompt": "Before the air's last stop, label both lungs! Right and left mean the body's own sides.",
		},
	]


func _build_stations() -> void:
	stations = [
		{
			"name": "Nose & Mouth", "boxes": ["nasal", "oral"], "helpers": [],
			"info": "Air comes in through the nose (nasal cavity) or the mouth (oral cavity). Hairs and sticky mucus in the nose trap dust and germs, and the air is warmed and made moist before it reaches the lungs.",
		},
		{
			"name": "Pharynx", "boxes": ["pharynx"], "helpers": [],
			"info": "The pharynx is the throat. The nose and mouth both open into it, and it carries air to the larynx and food to the esophagus.",
		},
		{
			"name": "Larynx", "boxes": ["larynx"], "helpers": [],
			"info": "The larynx is the voice box. Air passing over its vocal cords makes them vibrate, which makes sound. A flap called the epiglottis covers it when you swallow, so food doesn't go down the airway.",
		},
		{
			"name": "Trachea", "boxes": ["trachea"], "helpers": [],
			"info": "The trachea, or windpipe, is the largest airway. Rings of cartilage keep it open so air can always get through.",
		},
		{
			"name": "Left Bronchus", "boxes": ["left_bronchus"], "helpers": ["right_bronchus"],
			"info": "The trachea splits into two bronchi, one for each lung. The left bronchus carries air into the left lung, and the right bronchus does the same for the right lung.",
		},
		{
			"name": "Bronchioles", "boxes": ["bronchioles"], "helpers": ["left_lung", "right_lung"],
			"info": "The bronchi branch into smaller and smaller bronchioles, ending in tiny air sacs called alveoli. Oxygen passes through their thin walls into the blood, and carbon dioxide passes out. Both lungs do this; the one on the right of the picture is cut open.",
		},
	]
	for i: int in stations.size():
		stations[i]["pos"] = AIRFLOW[STATION_INDEX[i]]


func _build_segments() -> void:
	start_pos = AIRFLOW[0]
	segments.clear()
	segment_switch_t.clear()
	var from: int = 0
	for i: int in stations.size():
		var to: int = STATION_INDEX[i]
		segments.append(PackedVector2Array(AIRFLOW.slice(from, to + 1)))
		var span: float = _cum[to] - _cum[from]
		segment_switch_t.append(clampf((_cum[REGION_START[i]] - _cum[from]) / span, 0.0, 1.0) if span > 0.0 else 1.0)
		from = to


# ---------------------------------------------------------------- airflow path helpers

func _build_cumulative() -> void:
	_cum.resize(AIRFLOW.size())
	_cum[0] = 0.0
	for i: int in range(1, AIRFLOW.size()):
		_cum[i] = _cum[i - 1] + AIRFLOW[i - 1].distance_to(AIRFLOW[i])


func path_length() -> float:
	return _cum[_cum.size() - 1]


## Distance along the airflow path where station `index`'s region begins.
func region_start_distance(index: int) -> float:
	return _cum[REGION_START[index]]


## Distance along the airflow path at AIRFLOW[index].
func distance_at_index(index: int) -> float:
	return _cum[clampi(index, 0, _cum.size() - 1)]


## Station whose region contains distance `d` (-1 before the nostril).
func region_at(d: float) -> int:
	if d < 0.0:
		return -1
	var found: int = 0
	for i: int in REGION_START.size():
		if d >= _cum[REGION_START[i]]:
			found = i
	return found


## Point at distance `d` along the path. Below 0 it carries on straight out of the nostril.
func point_at(d: float) -> Vector2:
	if d <= 0.0:
		var out_dir: Vector2 = (AIRFLOW[0] - AIRFLOW[1]).normalized()
		return AIRFLOW[0] + out_dir * (-d)
	var i: int = _index_at(d)
	if i >= AIRFLOW.size() - 1:
		return AIRFLOW[AIRFLOW.size() - 1]
	var piece: float = _cum[i + 1] - _cum[i]
	var f: float = 0.0 if piece <= 0.0 else (d - _cum[i]) / piece
	return AIRFLOW[i].lerp(AIRFLOW[i + 1], clampf(f, 0.0, 1.0))


## Unit normal (left of travel direction) at distance `d`, smoothed over a few samples.
func normal_at(d: float) -> Vector2:
	var a: Vector2 = point_at(d - 9.0)
	var b: Vector2 = point_at(d + 9.0)
	var dir: Vector2 = b - a
	if dir.length_squared() < 0.0001:
		return Vector2.UP
	return dir.normalized().orthogonal()


## 0 outside the cut-open lung, 1 inside: how much a gas dot at distance `d` moves with it.
func lung_weight(d: float) -> float:
	return smoothstep(_cum[LUNG_BLEND_FROM], _cum[LUNG_BLEND_TO], d)


func _index_at(d: float) -> int:
	var lo: int = 0
	var hi: int = _cum.size() - 1
	while hi - lo > 1:
		var mid: int = (lo + hi) >> 1
		if _cum[mid] <= d:
			lo = mid
		else:
			hi = mid
	return lo
