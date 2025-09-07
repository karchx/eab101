const std = @import("std");

fn phiOfN(p: i32, q: i32) i32 {
    return (p - 1) * (q - 1);
}

fn equivalentModPhi(a: i32, b: i32, phi: i32) i32 {
    return @mod((a - b), phi);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const p = 7;
    const q = 13;
    const phi = phiOfN(p, q);

    try stdout.print("RSA setup: p = {d}, q = {d}, φ(n) = {d}\n", .{p, q, phi});

    const a = 35;
    const b = 99;

    if (equivalentModPhi(a, b, phi) == 0) {
        try stdout.print("{d} = {d} (mod {d})\n", .{a, b, phi});
    } else {
        try stdout.print("{d} ≠ {d} (mod {d})\n", .{a, b, phi});
    }
}

