# board4.s ... Game of Life on a 3x3 grid

	.data

N:	.word 3  # gives board dimensions

board:
	.byte 1, 0, 0
	.byte 1, 1, 0
	.byte 0, 0, 0

newBoard: .space 9
