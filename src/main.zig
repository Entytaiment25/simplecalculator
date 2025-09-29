const std = @import("std");

fn parseExpression(input: []const u8) !struct { f64, u8, f64 } {
    var tokens = std.mem.tokenizeScalar(u8, input, ' ');

    const first_str = tokens.next();
    const operation_str = tokens.next();
    const second_str = tokens.next();

    if (operation_str == null or operation_str.?.len != 1) return error.InvalidInput;

    const first = if (first_str) |str| try std.fmt.parseFloat(f64, str) else 0;
    const second = if (second_str) |str| try std.fmt.parseFloat(f64, str) else 0;

    return .{ first, operation_str.?[0], second };
}

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Enter your Calculation: ", .{});
    try stdout.flush();

    var input_buffer: [256]u8 = undefined;
    const bytes_read = try std.fs.File.stdin().read(&input_buffer);
    const input = if (bytes_read > 0) std.mem.trim(u8, input_buffer[0..bytes_read], " \t\r\n") else "";

    if (input.len == 0) {
        try stdout.print("No input received.\n", .{});
        try stdout.flush();
        return;
    }

    const first: f64, const operation: u8, const second: f64 = parseExpression(input) catch {
        try stdout.print("Invalid input format. Please use format: number operator number (e.g., 1 + 1)\n", .{});
        try stdout.flush();
        return;
    };

    const result: struct { ?f64, ?[]const u8 } = switch (operation) {
        '+' => .{ first + second, null },
        '-' => .{ first - second, null },
        '*' => .{ first * second, null },
        '/' => .{ first / second, null },
        else => .{ null, "Invalid operation. Supported operations: (+, -, *, /)" },
    };

    if (result.@"0") |value| try stdout.print("Result: {d}\n", .{value});
    if (result.@"1") |str| try stdout.print("{s}\n", .{str});

    try stdout.flush();
}
