const std = @import("std");
const net = std.net;
const proto = @import("protocol.zig");
const KV = @import("kv.zig").KV;

pub fn main() !void {
    const gpa = std.heap.page_allocator;
    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <port>\n", .{"tcp_server"});
        return;
    }
    const port = try std.fmt.parseInt(u16, args[1], 10);
    const address = try net.Address.parseIp("127.0.0.1", port);
    var server = try address.listen(.{ .reuse_address = true});
    defer server.deinit();

    std.debug.print("listening on {d}...\n", .{port});

    var store = KV.init(gpa);
    defer store.deinit();

    while (true) {
        std.debug.print("waiting for connection...\n", .{});
        const conn = try server.accept();
        defer conn.stream.close();

        var br = std.io.bufferedReader(conn.stream.reader());
        var r = br.reader();
        const w = conn.stream.writer();
        std.debug.print("accepted connection from {any}\n", .{conn.address});
        while (true) {
            const line = try r.readUntilDelimiterOrEofAlloc(gpa, '\n', 64 * 1024);
            if (line == null) break;
            defer gpa.free(line.?);

            const res = handle(line.?, &store) catch |e| {
                try proto.writeResponse(w, .{ .Err = @errorName(e) });
                continue;
            };
            try proto.writeResponse(w, res);
        }
    }
}

fn handle(line: []const u8, store: *KV) !proto.Response {
    const cmd = try proto.parseLine(line);
    switch (cmd) {
        .Put => |p| {
            try store.put(p.key, p.val);
            return .Ok;
        },
        .Get => |g| {
            if (store.get(g.key)) |v| return proto.Response{ .Value = v };
            return .NotFound;
        },
        .Del => |d| {
            return if (store.del(d.key)) .Ok else .NotFound;
        }
    }
}
