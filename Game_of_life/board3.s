# board1.s ... Game of Life on a 10x10 grid

	.data

N:	.word 4  # gives board dimensions

board:
	.byte 1, 0, 0, 0
	.byte 1, 1, 0, 0
	.byte 0, 0, 0, 1
	.byte 0, 0, 1, 0


newBoard: .space 16
