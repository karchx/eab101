const std = @import("std");

pub const Pair = struct {
    a: usize,
    b: usize,
};

pub fn buildAdjacencyMatrix(
    allocator: std.mem.Allocator,
    n: usize,
    relation: []const Pair,
) ![][]u8{
    var matrix = try allocator.alloc([]u8, n);
    for (matrix) |*row| {
        row.* = try allocator.alloc(u8, n);
        @memset(row.*, 0);
    }

    for (relation) |p| {
        matrix[p.a - 1][p.b - 1] = 1;
    }
    return matrix;
}

pub fn printMatrix(matrix: [][]u8, stdout: anytype) !void {
    for (matrix) |row| {
        for (row) |val| {
            try stdout.print("{d} ", .{val});
        }
        try stdout.print("\n", .{});
    }
}
