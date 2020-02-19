# board2.s ... Game of Life on a 15x15 grid

	.data

N:	.word 15  # gives board dimensions

board:
	.byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0
	.byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
	.byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0

newBoard: .space 225
# COMP1521 19t2 ... Game of Life on a NxN grid
#
# Written by Oren Levy, June/July 2019
# Student ID: Z3466301

## Requires (from `boardX.s'):
# - N (word): board dimensions
# - board (byte[][]): initial board state
# - newBoard (byte[][]): next board state

## Provides:
	.globl	main
	.globl	decideCell
	.globl	neighbours
	.globl	copyBackAndShow


########################################################################
# .TEXT <main>

    .data
msg_num_iterations:      .asciiz "# Iterations: "
msg_after_iteration_1:   .asciiz "=== After iteration "
msg_after_iteration_2:   .asciiz " ==="
eol: 										 .asciiz "\n"
print_dot:   						 .asciiz "."
print_hash:   					 .asciiz "#"

	.text
	.globl main

# Your main program code goes here.  Good luck!

main:

	# Prologue : Build the stack
	addi	$sp,  $sp, -4
	sw		$fp, ($sp)	# push $fp
	la		$fp, ($sp)	# load new $fp
	addi	$sp,  $sp, -4
	sw		$ra, ($sp)	# push $ra

    # Begin requesting info from user
	la		$a0, msg_num_iterations
	li		$v0, 4
	syscall			# printf("# Iterations: ")
	li		$v0, 5
	syscall			# scanf("%d", &maxiters)
	move	$s0, $v0	# $s0 = maxiters (save into s0 num iterations)

	lw 		$s1, N		# $s1 = N dimensions (Read from the address of N)
	li 		$s2, 0		# $s2 serves as our maxiters loop counter

# Put your other functions here

# for (int n = 1; n <= maxiters; n++) {
maxiters_loop:
	beq		$s2, $s0, end_maxiters_loop		# if n (maxIter loop counter) == MaxIterations we have exhausted the desired iterations, exit main
	li		$s3, 0							# Row Counter, reset to 0 at the start of each new row

	# for (int i = 0; i < N; i++) {
	maxiters_row_loop:
		beq		$s3, $s1, end_maxiters_row_loop  # if Row ($s3=i) == N (array dimensions), weve gone through entire array, end and continue iterations
		li		$s4, 0								  		# Col Counter, reset to 0 at the start of each new col

		 # for (int j = 0; j < N; j++) {
		 maxiters_col_loop:
		 	 beq		$s4, $s1, end_maxiters_col_loop  # if Col ($s4=j) == N, reached end of col, end and continue to next row
			 mul		$t0, $s3, $s1						# Row offset = row*N
			 add		$t0, $t0, $s4						# Col offset = Row offset + Col Counter ((R*N)+(C))
			 lb		  $t1, board($t0)					    # Load the element in board[Row][Col] -- stored at offset location $t0 into $t1

			 move		$s5, $t0								# To be used later when creating the new board
			 move		$a0, $s3								# Argument i for Neighbours function: (i) = (Row = $a0 = i)
			 move		$a1, $s4								# Argument j for Neighbours function: (j) = (Col = $a1 = j)

			 jal	neighbours
			 move		$a2, $v0								# int nn = neighbours (i, j); $a2 = $v0 = nn (# of Neighbours) returned from find_neighbours function
		     move		$a3, $t1							    # $a3 = board[i][j]

			 jal decideCell
			 move		$t5, $v1								# $t5 = 0 or 1, representing dead or living cell to be added to newBoard

			 sb			$t5, newBoard($s5)                      # newBoard[row][column] = $t5

			 addi		$s4, $s4, 1								# Col++
			 j	maxiters_col_loop

		 end_maxiters_col_loop:
		   addi		$s3, $s3, 1									# Row++
			 j maxiters_row_loop

	end_maxiters_row_loop:
		addi	$s2, $s2, 1									   # maxIters++

		# printf"=== After iteration %d ===\n", n);
		la		$a0, msg_after_iteration_1              # "=== After iteration
		li    $v0, 4
		syscall
		move	$a0, $s2
		li		$v0, 1
		syscall					                        # In C it is: printf("%d")
		la    $a0, msg_after_iteration_2
		li    $v0, 4
		syscall					                        # In C it is: printf(" ===")
		la    $a0, eol
		syscall					                        # In C it is: printf("\n")

		jal copyBackAndShow	                            
		j maxiters_loop

end_maxiters_loop:

	# Epilogue : Destroy the stack
	lw	    $ra, ($sp)	# pop $ra
	addi	$sp,  $sp, 4
	lw	    $fp, ($sp)	# pop $fp
	addi	$sp,  $sp, 4

	# Return end function
	jr	$ra

decideCell:

# Any live cell with fewer than two live neighbours dies, as if caused by underpopulation.
# Any live cell with two or three live neighbours lives on to the next generation.
# Any live cell with more than three live neighbours dies, as if by overpopulation.
# Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

	blt		$a2, 2, fewer_than_two_neighbours
	beq		$a2, 2, two_or_three_neighbours
	beq		$a2, 3, two_or_three_neighbours
	bgt		$a2, 3, more_than_three_neighbours

	fewer_than_two_neighbours:
		j	terminate_cell

	two_or_three_neighbours:
		beqz	$a3, dead_cell	            # board[i][j] = 0, (dead cell) attempt reproduction
		j	subsist_cell

	more_than_three_neighbours:
		j	terminate_cell

	dead_cell:
		bne		$a2, 3, terminate_cell      # if nn != 3, remain as dead cell
		j	subsist_cell				    # else we revive cell

	terminate_cell:
		li		$v1, 0						# Let cell = 0 representing death
		jr		$ra

	subsist_cell:
		li		$v1, 1						# Let cell = 1 representing life
		jr		$ra


neighbours:
	li		$t2, 0	     # nn = 0 is our neighbours counter, assume no neighbours exist
	li		$t3, -2      # Neighbours x_loop counter (row loop counter)
	li		$t4, -2	     # Neighbours y_loop counter (col loop counter)
	addi	$t5, $s1, -1 # $t5 = N-1

	neighbours_row_loop_x:
		addi	$t3, $t3, 1	             # Row++
		bgt		$t3, 1, end_neighbours   # end_neigh if iterated through each row
		li		$t4, -2	                 # Reset y_loop counter at the start of each new row

		neighbours_col_loop_y:
			addi	$t4, $t4, 1	                  # Col++
			bgt		$t4, 1, neighbours_row_loop_x # if y > 1 end col loop

# if (i + x < 0 || i + x > N - 1) continue;
			add		$t6, $t3, $a0		          # $t6 = x + i, where i is the row passed as argument
			bltz	$t6, neighbours_col_loop_y	  # if i + x < 0 continue
			bgt		$t6, $t5, neighbours_col_loop_y # if i + x > N - 1 continue

# if (j + y < 0 || j + y > N - 1) continue;
			add		$t7, $t4, $a1		            # $t7 = y + j, where i is the row passed as argument
			bltz	$t7, neighbours_col_loop_y	    # if y + j < 0 continue
			bgt		$t7, $t5, neighbours_col_loop_y # if j + y > N - 1 continue

# if (x == 0 && y == 0) continue; Below we check for reverse
			bnez	$t3, check_neighbouring_cell	# if x != 0
			bnez	$t4, check_neighbouring_cell	# if y != 0

			j	neighbours_col_loop_y

			check_neighbouring_cell:
				mul		$t8, $t6, $s1		# Find the row we are in (i+x)*N
				add		$t8, $t8, $t7		# Add the colum offset (row+(i+x))
				lb		$t9, board($t8)	    # $t9 = board($t8) Retrieve the value stored in memory position and store in t9

				bne	  $t9, 1, neighbours_col_loop_y # if board(val) is != 1, continue search
				addi	$t2, $t2, 1					# nn++

				j neighbours_col_loop_y				# Continue looping through colums

end_neighbours:
	move	$v0, $t2    # Return the number of neigbours by storing nn in v0
	jr $ra


copyBackAndShow:
	li		$t0, 0		# $t0 = i = 0
	li		$t1, 0		# $t1 = j = 0

	cbs_loop_i:
		beq		$t0, $s1, end_cbs  # if Row($t0=i) == N(array dimensions) end loop
		li		$t1, 0			   # Col Counter (j), reset to 0 at the start of each new col

		cbs_loop_j:
			beq		$t1, $s1, end_cbs_loop_j  # if (j == N) return to cbs_loop_i

			mul		$t2, $t0, $s1			  # Row offset = row*N
			add		$t2, $t2, $t1			  # Col offset = Row offset + Col Counter ((R*N)+(C))
			lb		$t3, newBoard($t2)		  # Load the element in newBoard[Row][Col] -- stored at offset location $t2 into $t3
			sb		$t3, board($t2)			  # Load the element in board[Row][Col] -- stored at offset location $t2 into $t3

			beqz	$t3, print_dead_cell	  # if (board[i][j] == 0) print dead cell

			print_living_cell:
				la   $a0, print_hash		  # Load '#' representing living cell
				li   $v0, 4
				syscall						  # printf("#");

				j continue_printing_cell	  # jump to continue_printing_cell


			print_dead_cell:
				la   $a0, print_dot		      # Load '.' representing dead cell
				li   $v0, 4
				syscall						  # printf(".");

				j continue_printing_cell	  # jump to continue_printing_cell

		continue_printing_cell:
			addi	$t1, $t1, 1				  # Col++
			j	cbs_loop_j

	end_cbs_loop_j:
		la   $a0, eol
		li   $v0, 4
		syscall					              # printf("\n")

		addi	$t0, $t0, 1				      # Row++
		j	cbs_loop_i

end_cbs:
	jr	$ra

