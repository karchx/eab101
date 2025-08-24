const std = @import("std");

pub fn isReflexive(matrix: [][]u8) bool {
    const n = matrix.len;
    for (0..n) |i| {
        if (matrix[i][i] != 1) return false;
    }
    return true;
}

pub fn inRelation(x: i32, y: i32) bool {
    return @mod(y - x, 3) == 0;
}

pub fn isReflexiveOnRange(start: i32, end: i32) bool {
    for (start..end+1) |val| {
        const v: i32 = @intCast(val);
        if (!inRelation(v, v)) {
            return false;
        }
    }
    return true;
}
