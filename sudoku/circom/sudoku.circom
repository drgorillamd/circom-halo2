pragma circom 2.1.7;

// Prove that a given solution is a valid sudoku solution
template Sudoku () {
    signal input question[9][9];
    signal input solution[9][9];

    // Validate the solution contains the question
    for(var i = 0; i < 9; i++) {
        for(var j = 0; j < 9; j++) {
            assert(question[i][j] == 0 || question[i][j] == solution[i][j]);
        }
    }

    // Validate the solution is correct row-wise (only unique values in 1-9)
    for(var i = 0; i < 9; i++) {
        var unique_elements_row[9];
        var unique_elements_col[9];

        for(var j = 0; j < 9; j++) {
            assert(unique_elements_row[solution[i][j] - 1] == 0);
            unique_elements_row[solution[i][j] - 1] = 1;

            assert(unique_elements_col[solution[j][i] - 1] == 0);
            unique_elements_col[solution[j][i] - 1] = 1;
        }
    }

    // Validate each blocks
    for(var block_x = 0; block_x < 3; block_x++) {
        for(var block_y = 0; block_y < 3; block_y++) {
            // Validate the current block
            var unique_elements_block[9];

            for(var i = 0; i < 3; i++) {
                for(var j = 0; j < 3; j++) {
                    assert(unique_elements_block[solution[(block_x * 3) + i][(block_y * 3) + j]] == 0);
                    unique_elements_block[solution[(block_x * 3) + i][(block_y * 3) + j]] = 1;
                }
            }
        }
    }
}

component main = Sudoku();