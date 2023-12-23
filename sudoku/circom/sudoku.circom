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

    // Validate the solution is correct row- and column-wise (ie only unique values in 1-9)
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
    for(var start_offset_x = 0; start_offset_x < 9; start_offset_x += 3) {
        for(var start_offset_y = 0; start_offset_y < 9; start_offset_y += 3) {
            // Validate the current block
            var unique_elements_block[9];

            for(var i = start_offset_x; i < start_offset_x + 3; i++) {
                for(var j = start_offset_y; j < start_offset_y + 3; j++) {
                    assert(unique_elements_block[solution[i][j] - 1] == 0);
                    unique_elements_block[solution[i][j] - 1] = 1;
                }
            }
        }
    }
}

component main = Sudoku();