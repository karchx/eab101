const std = @import("std");

pub fn isReflexive(matrix: [][]u8) bool {
    const n = matrix.len;
    for (0..n) |i| {
        if (matrix[i][i] != 1) return false;
    }
    return true;
}
