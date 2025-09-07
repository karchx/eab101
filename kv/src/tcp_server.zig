const std = @import("std");
const net = std.net;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <port>\n", .{});
        return;
    }
    const port = try std.fmt.parseInt(u16, args[1], 10);
    const address = try net.Address.parseIp("127.0.0.0", port);
    var server = try address.listen(.{ .reuse_address = true});
    defer server.deinit();

    std.debug.print("listening on {d}...\n", .{port});

    while (true) {
        const conn = try server.accept();
        defer conn.stream.close();
        std.debug.print("{s} connected\n", .{"test"});
        try conn.stream.writer().print("Hello, World!\n", .{});
    }
}
