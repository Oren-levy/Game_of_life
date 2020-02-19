// Game of Life on a 4x4 grid

#define NN 4

int N = NN;

char board[NN][NN] = {
	{1,0,0,0},
	{1,1,0,0},
	{0,0,0,1},
	{0,0,1,0},

};
char newboard[NN][NN];
