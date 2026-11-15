extends Node2D

const W := 960.0
const H := 540.0
var player := Vector2(480, 260)
var velocity := Vector2(150, 0)
var platforms := [Rect2(350, 420, 180, 18), Rect2(90, 315, 150, 18), Rect2(620, 245, 150, 18), Rect2(330, 145, 170, 18)]
var gems := [Vector2(165, 280), Vector2(695, 210), Vector2(415, 110)]
var spikes := [Rect2(420, 490, 120, 18)]
var score := 0
var game_over := false
var font = ThemeDB.fallback_font

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and game_over:
		get_tree().reload_current_scene()
	if game_over:
		queue_redraw()
		return
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = move_toward(velocity.x, direction * 280.0, 900.0 * delta)
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0.0, 350.0 * delta)
	velocity.y += 900.0 * delta
	var old_y := player.y
	player += velocity * delta
	player.x = wrapf(player.x, 18.0, W - 18.0)
	for p in platforms:
		if velocity.y > 0 and old_y + 16 <= p.position.y and player.y + 16 >= p.position.y and player.x > p.position.x - 12 and player.x < p.end.x + 12:
			player.y = p.position.y - 16
			velocity.y = -520
	for i in range(gems.size() - 1, -1, -1):
		if player.distance_to(gems[i]) < 28:
			gems.remove_at(i)
			score += 1
	for s in spikes:
		if s.has_point(player):
			game_over = true
	if player.y > H + 40:
		game_over = true
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#101b35"))
	for x in range(0, 960, 48):
		draw_line(Vector2(x, 0), Vector2(x, H), Color("#1b2a49"), 1)
	for y in range(0, 540, 48):
		draw_line(Vector2(0, y), Vector2(W, y), Color("#1b2a49"), 1)
	for p in platforms:
		draw_rect(p, Color("#36c6b4"), true)
		draw_rect(Rect2(p.position.x, p.position.y, p.size.x, 5), Color("#a5fff0"), true)
	for g in gems:
		draw_circle(g, 10, Color("#ffd34e"))
		draw_circle(g, 4, Color("#fff3b0"))
	for s in spikes:
		draw_rect(s, Color("#ef5261"))
	draw_circle(player, 16, Color("#ff914d"))
	draw_circle(player + Vector2(-5, -5), 5, Color("#ffd0a8"))
	draw_string(font, Vector2(24, 38), "BOUNCE BACK   •   Gems: %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
	draw_string(font, Vector2(24, 68), "Move: A/D or arrow keys    |    Bounce automatically", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#b9c7e6"))
	if game_over:
		draw_rect(Rect2(250, 185, 460, 160), Color("#081124"))
		draw_string(font, Vector2(355, 245), "TRY AGAIN!", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color("#ffd34e"))
		draw_string(font, Vector2(310, 290), "Press ENTER to restart", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
