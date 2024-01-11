pragma circom 2.1.5;

include "../../node_modules/circomlib/circuits/comparators.circom";

// takes 2 private signals in (a and b) and a public one (c).
// checks if the matrix a[M][N] . b[N][P] == c[M][P]
template CheckMatrixProduct(M,N,P) {
    // A . B = C with dim(A) = MxN, dim(B)=NxP and dim(C)=NxN
    signal input a[M][N]; // private
    signal input b[N][P]; // private
    signal input c[M][P]; // public

    // compiler check: valid matrices (NOT a constrain)
    assert(M * N * P != 0);

    // 1 if the dot product a[x][i] . b[i][y] == c[x][y]
    component isDotProd[M][P];

    // for row in c
    for(var i = 0; i < M; i++) {
        // for col in c
        for(var j = 0; j < P; j++) {

            isDotProd[i][j] = IsDotProductEq(N);

            // Circom 2.1: pass a whole vector and this is so cool
            isDotProd[i][j].a <== a[i];

            // transposed
            for(var k = 0; k < N; k++) {
                isDotProd[i][j].b[k] <== b[k][j];
            }
            
            // the result in c
            isDotProd[i][j].dot_product <== c[i][j];

            isDotProd[i][j].isEqual === 1;
        }
    }
}

// Returns 1 if the dot product between 2 vectors a[N] and b[N] == dot_product
template IsDotProductEq(N) {
    signal input a[N];
    signal input b[N];
    signal input dot_product;

    signal output isEqual;

    // working vectors:
    // product of each value in a and b
    signal products[N];

    // cumulative sums of the products
    signal cum_sum[N];

    component isEq = IsEqual();

    // hold the first (rest iterate on i-1, avoid falling out of bound)
    products[0] <== a[0] * b[0];
    cum_sum[0] <== products[0];
    
    // compute a[i] * b[i] then add it to the cumulative sum
    for(var i = 1; i < N; i++) {
        products[i] <== a[i] * b[i];
        cum_sum[i] <== cum_sum[i - 1] + products[i];
    }

    // the last value of cum_sum now holds the dot product, just check for eq and return it
    isEq.in[0] <== dot_product;
    isEq.in[1] <== cum_sum[N - 1];
    isEqual <== isEq.out;
}

component main { public [ c ] } = CheckMatrixProduct(2, 3, 2);