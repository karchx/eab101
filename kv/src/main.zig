const std = @import("std");
const net = std.net;
const posix = std.posix;


pub fn main() !void {
    const address = try std.net.Address.parseIp("127.0.0.0", 5882);

    const tpe: u32 = posix.SOCK.STREAM;
    const protocol = posix.IPPROTO.TCP;
    const listener = try posix.socket(address.any.family, tpe, protocol);
    defer posix.close(listener);

    try posix.setsockopt(listener, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
    try posix.bind(listener, &address.any, address.getOsSockLen());
    try posix.listen(listener, 128);

    std.debug.print("listening on 5882...\n", .{});

    while (true) {
        var client_addr: net.Address = undefined;
        var client_addr_len: posix.socklen_t = @sizeOf(net.Address);

        const socket = posix.accept(listener, &client_addr.any, &client_addr_len, 0) catch |err| {
            std.debug.print("accept error: {}\n", .{err});
            continue;
        };
        defer posix.close(socket);
        std.debug.print("{} connected\n", .{client_addr});
        write(socket, "Hello, World!\n") catch |err| {
            std.debug.print("write error: {}\n", .{err});
        };

    }
}

fn write(socket: posix.socket_t, msg: []const u8) !void {
    var pos: usize = 0;
    while (pos < msg.len) {
        const written = try posix.write(socket, msg[pos..]);
        if (written == 0) {
            return error.Closed;
        }
        pos += written;
    }
}
