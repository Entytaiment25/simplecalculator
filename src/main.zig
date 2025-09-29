const std = @import("std");

fn parseExpression(input: []const u8) !struct { first: f64, op: u8, second: f64 } {
    var tokens = std.mem.tokenizeScalar(u8, input, ' ');

    const first_str = tokens.next() orelse return error.InvalidInput;
    const op_str = tokens.next() orelse return error.InvalidInput;
    const second_str = tokens.next() orelse return error.InvalidInput;

    if (op_str.len != 1) return error.InvalidInput;

    const first = std.fmt.parseFloat(f64, first_str) catch return error.InvalidInput;
    const second = std.fmt.parseFloat(f64, second_str) catch return error.InvalidInput;

    return .{ .first = first, .op = op_str[0], .second = second };
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

    const expr = parseExpression(input) catch {
        try stdout.print("Invalid input format. Please use format: number operator number (e.g., 1 + 1)\n", .{});
        try stdout.flush();
        return;
    };

    switch (expr.op) {
        '+' => try stdout.print("Result: {}\n", .{expr.first + expr.second}),
        '-' => try stdout.print("Result: {}\n", .{expr.first - expr.second}),
        '*' => try stdout.print("Result: {}\n", .{expr.first * expr.second}),
        '/' => {
            if (expr.second == 0.0) {
                try stdout.print("Error: Division by zero.\n", .{});
            } else {
                try stdout.print("Result: {}\n", .{expr.first / expr.second});
            }
        },
        else => try stdout.print("Invalid operation. Supported operations: +, -, *, /\n", .{}),
    }

    try stdout.flush();
}
