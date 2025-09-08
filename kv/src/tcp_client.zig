const std = @import("std");
const Ring = @import("ring.zig").Ring;
const properties = @import("properties.zig");
const proto = @import("protocol.zig");

fn sendLine(addr: []const u8, line: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var client = try std.net.tcpConnectToAddress(try std.net.Address.parseIp4("127.0.0.1", try parsePort(addr)));

    defer client.close();

    try client.writer().print("{s}\n", .{line});
    var br = std.io.bufferedReader(client.reader());
    var r = br.reader();

    const first = try r.readUntilDelimiterAlloc(allocator, '\n', 64 * 1024);
    defer allocator.free(first);

    if (std.mem.startsWith(u8, first, "VALUE")) {
        const val = try r.readUntilDelimiterAlloc(allocator, '\n', 64 * 1024);
        return val;
    } else {
        return try allocator.dupe(u8, first);
    }
}

fn parsePort(addr: []const u8) !u16 {
    const idx = std.mem.lastIndexOfScalar(u8, addr, ':') orelse return error.BadAddr;
    return try std.fmt.parseInt(u16, addr[idx + 1..], 10);
}

pub fn main() !void {
    const gpa = std.heap.page_allocator;

    var addrs = [_][]const u8{
        //"127.0.0.1:9091",
        "127.0.0.1:9092",
        "127.0.0.1:9093",
    };

    var ring = try Ring.init(gpa, addrs[0..], 50); // 50 virtual nodes per address
    defer ring.deinit(gpa);

    //const rf: usize = 2;

    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    if (args.len < 3) {
        std.debug.print("usage: {s} <PUT|GET|DEL> <key> [value]\n", .{args[0]});
        return;
    }
    const op = args[1];
    const key = args[2];

    const owner = ring.pick(key);
    var line_buf: [2048]u8 = undefined;

    const line = blk: {
        if (std.mem.eql(u8, op, "PUT")) {
            if (args.len < 4) {
                std.debug.print("missing value\n", .{});
                return;
            }

    break :blk try std.fmt.bufPrint(&line_buf, "PUT {s} {s}", .{key, args[3]});
        } else if (std.mem.eql(u8, op, "GET")) {
    break :blk try std.fmt.bufPrint(&line_buf, "GET {s}", .{key});
        } else if (std.mem.eql(u8, op, "DEL")) {
    break :blk try std.fmt.bufPrint(&line_buf, "DEL {s}", .{key});
        } else {
            std.debug.print("unknown op: {s}\n", .{op});
            return;
        }
    };

    const resp = try sendLine(owner.id, line, gpa);
    defer gpa.free(resp);
    std.debug.print("-> [{s}] {s}\n", .{owner.id, resp});
}
