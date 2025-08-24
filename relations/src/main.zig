const std = @import("std");
const relation = @import("relation.zig");
const properties = @import("properties.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();

    const R = [_]relation.Pair{
        .{ .a = 1, .b = 1 },
        .{ .a = 2, .b = 2 },
        .{ .a = 3, .b = 3 },
    };

    const n: usize = R.len;

    const matrix = try relation.buildAdjacencyMatrix(allocator, n, &R);

    try stdout.print("Adjacency Matrix:\n", .{});
    try relation.printMatrix(matrix, stdout);

    if (properties.isReflexive(matrix)) {
        try stdout.print("The relation is reflexive.\n", .{});
    } else {
        try stdout.print("The relation is not reflexive.\n", .{});
    }

    try stdout.print("(4,1) ∈ R? {}\n", .{properties.inRelation(4,1)});
    try stdout.print("(5,5) ∈ R? {}\n", .{properties.inRelation(4,4)});
    try stdout.print("(25, 5) ∈ R? {}\n", .{properties.inRelation(25, 5)});

}
