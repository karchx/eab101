const std = @import("std");

fn simpleHash(x: i32, bucket_count: i32) i32 {
    return @mod(x, bucket_count);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const bucket_count = 5;

    const values = [_]i32{12, 17, 22, 37, 42};

    try stdout.print("Hashing with {d} buckets:\n", .{bucket_count});

    for (values) |val| {
        try stdout.print("Value: {d}, Bucket: {d}\n", .{val, simpleHash(val, bucket_count)});
    }
}

