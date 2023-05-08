INC = constants.inc header.inc guard_registry.mac
SRC = main.s reset.s draw_player.s player_controls.s
OBJ = ${SRC:.s=.o}
CFG = nes.cfg
GRAPHIC = graphics.chr

all: output.nes
	/Applications/fceux.app/Contents/MacOS/fceux output.nes

output.nes: ${CFG} ${OBJ}
	ld65 -C $(CFG) ${OBJ} -o output.nes

main.o: main.s ${GRAPHIC} ${INC}
	ca65 main.s -o main.o

draw_player.o: draw_player.s ${GRAPHIC} ${INC}
	ca65 draw_player.s -o draw_player.o

%.o: %.s ${SRC} ${INC}
	ca65 $< -o $@

clean:
	rm *.nes *.o
