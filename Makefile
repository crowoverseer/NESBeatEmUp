INC = constants.inc header.inc object_states.inc fighting_constants.inc guard_registry.mac
SRC = main.s reset.s draw_player.s draw_sprite.s player_controls.s fighting_controller.s
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

reset.o: reset.s main.s ${INC}
	ca65 reset.s -o reset.o

clean:
	rm *.nes *.o
