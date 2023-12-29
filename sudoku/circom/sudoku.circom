pragma circom 2.1.5;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/gates.circom";

// Prove that a given solution (private) is a valid sudoku solution of a given question grid (piublic)
template Sudoku () {
    // public:
    signal input question[9][9];

    // private:
    signal input solution[9][9];

    // Validate that the solution contains the question (or the question contains a zero at that index)
    component validSolutionGrid[9][9];
    for(var i = 0; i < 9; i++) {
        for(var j = 0; j < 9; j++) {
            validSolutionGrid[i][j] = OR();

            // Either the solution value == question value, or question value == 0
            validSolutionGrid[i][j].a <== IsZero()(question[i][j]);
            validSolutionGrid[i][j].b <== IsEqual()([question[i][j], solution[i][j]]);

            validSolutionGrid[i][j].out === 1;
        }
    }

    // For each row & col vector in the solution matrix:
    // Check if all the values are in range (1;9) - 0 is not possible in the solution
    // Check if only if it contrains only unique values (1..9)
    component validSolutionColumn[9];

    for(var i = 0; i < 9; i++) {
        validSolutionColumn[i] = validateSolution();

        // Pass the whole row vector
        validateSolution()(solution[i]);

        // Pass the transposed column vector
        for(var j = 0; j < 9; j++) {
            validSolutionColumn[i].in[j] <== solution[j][i];
        }
    }

    // Validate each of the 9 3x3 submatrix (in range and only unique values)
    component validSolutionBlock[9];

    for(var i = 0; i < 9; i++) {
        validSolutionBlock[i] = validateSolution();
    }

    for(var x_axis = 0; x_axis < 3; x_axis++ ) {
        for(var y_axis = 0; y_axis < 3; y_axis++) {

            // Validate the current block
            for(var i = 0; i < 3; i++) {
                for(var j = 0; j < 3; j++) {
                    validSolutionBlock[x_axis * 3 + y_axis].in[i * 3 + j] <== solution[x_axis * 3 + i][y_axis * 3 + j];
                }
            }
        }
    }
}

// Take a vector as an input and check:
// - each value appears exactly once
// - each value are between 1 and 9 (x != 0 && x < 10)
template parallel validateSolution() {
    signal input in[9];
    
    // Comparison matrix of 2 vectors, here, we compare the vector with itself and the
    // matrix should be strictly diagonal (no duplicate value)
    component equalityMatrix[9][9];
    component valueInRange[9];
    component isNotZero[9];

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