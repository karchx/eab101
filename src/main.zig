const std = @import("std");
const relation = @import("relation.zig");

pub fn main() void {
    std.debug.print("Hello, {s}!\n", .{"Zig Build"});
    relation.doSomething();
}
