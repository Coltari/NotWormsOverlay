extends TileMapLayer

func _ready():
	Events.remove_cell.connect(explode_tile_at)

func place_at_pos(pos:Vector2):
	var coords = to_local(pos)
	set_cell(local_to_map(coords),0,Vector2i(0,0),0)

func update_tile_at(pos:Vector2i):
	if get_cell_source_id(Vector2i(pos.x,pos.y)) == -1:
		return
	#check tiles around this one - update which tile we've set based on that
	var setup = ""
	#x-0,y-1
	if get_cell_source_id(Vector2i(pos.x,pos.y-1)) == -1:
		setup += "0"
	else:
		setup += "1"
	#x-1,y-0
	if get_cell_source_id(Vector2i(pos.x-1,pos.y)) == -1:
		setup += "0"
	else:
		setup += "1"
	#00 - this cell
	#x+1,y-0
	if get_cell_source_id(Vector2i(pos.x+1,pos.y)) == -1:
		setup += "0"
	else:
		setup += "1"
	#x-0,y+1
	if get_cell_source_id(Vector2i(pos.x,pos.y+1)) == -1:
		setup += "0"
	else:
		setup += "1"
	
	if setup == "0111" || setup == "0000":
		set_cell(Vector2i(pos.x,pos.y),0,Vector2i(1,0),0)
	elif setup == "1111":
		set_cell(Vector2i(pos.x,pos.y),0,Vector2i(0,0),0)
	elif setup == "1110":
		set_cell(Vector2i(pos.x,pos.y),0,Vector2i(0,1),0)
	elif setup == "0011":
		set_cell(Vector2i(pos.x,pos.y),0,Vector2i(2,0),0)
	elif setup == "0101":
		set_cell(Vector2i(pos.x,pos.y),0,Vector2i(3,0),0)
	elif setup == "1010":
		set_cell(Vector2i(pos.x,pos.y),0,Vector2i(1,1),0)
	elif setup == "1100":
		set_cell(Vector2i(pos.x,pos.y),0,Vector2i(2,1),0)
	else:
		set_cell(Vector2i(pos.x,pos.y),0,Vector2i(0,0),0)

func explode_tile_at(global_pos,radius):
	var xstart : int = int(global_pos.x)-radius
	var ystart : int = int(global_pos.y)-radius
	var xend : int = int(global_pos.x)+radius
	var yend : int = int(global_pos.y)+radius
	
	for x in range(xstart,xend):
		for y in range(ystart,yend):
			var pos = Vector2(x,y)
			if pos.distance_to(global_pos) <= radius:
				var coords = to_local(pos)
				erase_cell(local_to_map(coords))

func is_tile_here(pos:Vector2):
	var coord = to_local(pos)
	if get_cell_source_id(local_to_map(coord)) == -1:
		return false
	else:
		return true

func remove_all_tiles():
	var rect = get_used_rect()
	for x in rect.end.x:
		for y in rect.end.y:
			erase_cell(Vector2i(x,y))

func update_all_tiles():
	var rect = get_used_rect()
	for x in rect.end.x:
		for y in rect.end.y:
			update_tile_at(Vector2i(x,y))

func count_tiles():
	var rect = get_used_rect()
	var count : float = 0.0
	for x in rect.end.x:
		for y in rect.end.y:
			if get_cell_source_id(Vector2i(x,y)) == 0:
				count+=1
	return count
