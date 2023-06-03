INC = constants.inc header.inc object_states.inc fighting_constants.inc guard_registry.mac npc_controller.inc
SRC = main.s reset.s draw_player.s draw_sprite.s player_controls.s fighting_controller.s npc_controller.s npc_data.s npc_artist.s
OBJ = ${SRC:.s=.o}
CFG = nes.cfg
GRAPHIC = graphics.chr

all: output.nes
	/Applications/fceux.app/Contents/MacOS/fceux output.nes

output.nes: ${CFG} ${OBJ}
	ld65 -C $(CFG) ${OBJ} -o output.nes

main.o: main.s ${GRAPHIC} ${INC} ${SRC}
	ca65 main.s -o main.o

draw_player.o: draw_player.s draw_player_fighting.s ${GRAPHIC} ${INC} object_states.inc draw_sprite.s
	ca65 draw_player.s -o draw_player.o

draw_sprite.o: draw_sprite.s ${GRAPHIC} ${INC}
	ca65 draw_sprite.s -o draw_sprite.o

player_controls.o: player_controls.s player_controls_fighting.s fighting_controller.s ${INC} object_states.inc fighting_constants.inc
	ca65 player_controls.s -o player_controls.o

fighting_controller.o: fighting_controller.s main.s fighting_constants.inc object_states.inc
	ca65 fighting_controller.s -o fighting_controller.o

npc_controller.o: npc_controller.s object_states.inc fighting_constants.inc npc_controller.inc
	ca65 npc_controller.s -o npc_controller.o

npc_data.o: npc_data.s ${CFG}
	ca65 npc_data.s -o npc_data.o

npc_artist.o: npc_artist.s ${CFG} npc_controller.inc npc_data.o
	ca65 npc_artist.s -o npc_artist.o

reset.o: reset.s main.s ${INC}
	ca65 reset.s -o reset.o

clean:
	rm *.nes *.o
