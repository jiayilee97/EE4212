function dist = loss(matrix1, matrix2)
matrix1 = matrix1 - matrix2;
dist = sum(sum(sum(matrix1 .^ 2)));