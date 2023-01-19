CC = dart

BUILD = compile exe

RUN = run

FLAGS = -o transcript.exe

build: cli.dart
	${CC} ${BUILD} ${FLAGS} cli.dart

run: cli.dart
	${CC} ${RUN} cli.dart