pragma circom 2.1.6;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/gates.circom";

// Prove that a given solution is a valid sudoku solution
template Sudoku () {
    signal input question[9][9];
    signal input solution[9][9];

    // Validate the solution contains the question (or the question contains a zero at that index)
    component questionCopied[9][9];
    component questionZero[9][9];
    component validDuo[9][9];

    for(var i = 0; i < 9; i++) {
        for(var j = 0; j < 9; j++) {
            questionCopied[i][j] = IsEqual();
            questionZero[i][j] = IsZero();
            validDuo[i][j] = OR();

            questionCopied[i][j].in[0] <== question[i][j];
            questionCopied[i][j].in[1] <== solution[i][j];

            questionZero[i][j].in <== question[i][j];

            validDuo[i][j].a <== questionZero[i][j].out;
            validDuo[i][j].b <== questionCopied[i][j].out;

            validDuo[i][j].out === 1;
        }
    }

    // For each row
    // Check if in range, incl 0
    // Check if question == solution or 0
    // Check if only unique values
    component validSolutionRow[9];
    component validSolutionColumn[9];
    
    for(var i = 0; i < 9; i++) {
        validSolutionRow[i] = validateSolution();
        validSolutionColumn[i] = validateSolution();

        validSolutionRow[i].in <== solution[i];

    }

    // // Validate each blocks (in range and only unique values)
    // for(var start_offset_x = 0; start_offset_x < 9; start_offset_x += 3) {
    //     for(var start_offset_y = 0; start_offset_y < 9; start_offset_y += 3) {
    //         // Validate the current block
    //         var unique_elements_block[9];

    //         for(var i = start_offset_x; i < start_offset_x + 3; i++) {
    //             for(var j = start_offset_y; j < start_offset_y + 3; j++) {
    //                 assert(unique_elements_block[solution[i][j] - 1] == 0);
    //                 unique_elements_block[solution[i][j] - 1] = 1;
    //             }
    //         }
    //     }
    // }
}

template validateSolution() {
    // Validate the solution is correct row- and column-wise (ie only unique values in 1-9)
    // elt x from in should only exist at an index i (fails if duplicated), given range has been constrained
    // -> store indexes in a matrix, which *must* be diagonal

    signal input in[9];

    component equalityMatrix[9][9];
    component valueInRange[9];
    component isNotZero[9]; // no 0 in the solution

    for(var i = 0; i < 9; i++) {
        for(var j = 0; j < 9; j++) {
            equalityMatrix[i][j] = IsEqual();
        }
        valueInRange[i] = LessThan(4); // Using 4 bits is enough
        isNotZero[i] = IsZero();
    }

    for(var i = 0; i < 9; i++) {
        isNotZero[i].in <== in[i];
        isNotZero[i].out === 0;

        valueInRange[i].in[0] <== in[i];
        valueInRange[i].in[1] <== 10;
        valueInRange[i].out === 1;

        for(var j = 0; j < 9; j++) {
            // check that in[i] == in[j] iff i==j
            equalityMatrix[i][j].in[0] <== in[i];
            equalityMatrix[i][j].in[1] <== (i == j) ? 0 : in[j];
            equalityMatrix[i][j].out === 0; 
        }
    }
}

component main { public[question] }= Sudoku();