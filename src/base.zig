const std = @import("std");

const Pair = struct {
    a: usize,
    b: usize,
};

pub fn main() !void {
    const R = [_]Pair {
        .{ .a = 1, .b = 2 },
        .{ .a = 2, .b = 3 },
        .{ .a = 3, .b = 1 },
    };
    const n: usize = 3; // len set

    const stdout = std.io.getStdOut().writer();
    // Relation paris
    try stdout.print("Relation pairs:\n", .{});
    for (R) |p| {
        try stdout.print("({d}, {d})\n", .{ p.a, p.b });
    }
    try stdout.print("\n\n", .{});

    // Adjacency matrix
    var matrix: [n][n]u8 = .{.{0} ** n} ** n;
    for (R) |p| {
        matrix[p.a - 1][p.b - 1] = 1;
    }
    try stdout.print("Adjacency matrix:\n", .{});
    for (matrix) |row| {
        for (row) |val| {
            try stdout.print("{d} ", .{val});
        }
        try stdout.print("\n", .{});
    }
    try stdout.print("\n\n", .{});

    // Directed graph
    try stdout.print("Directed graph:\n", .{});
    for (R) |p| {
        try stdout.print("{d} -> {d}\n", .{ p.a, p.b });
    }
}
