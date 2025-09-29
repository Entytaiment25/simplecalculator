const std = @import("std");

fn add(n1: f64, n2: f64) f64 {
    return n1 + n2;
}

fn subtract(n1: f64, n2: f64) f64 {
    return n1 - n2;
}

fn multiply(n1: f64, n2: f64) f64 {
    return n1 * n2;
}

fn divide(n1: f64, n2: f64) f64 {
    return n1 / n2;
}

fn parseExpression(input: []const u8) !struct { n1: f64, op: u8, n2: f64 } {
    var tokens = std.mem.tokenizeScalar(u8, input, ' ');

    const n1_str = tokens.next() orelse return error.InvalidInput;
    const op_str = tokens.next() orelse return error.InvalidInput;
    const n2_str = tokens.next() orelse return error.InvalidInput;

    if (op_str.len != 1) return error.InvalidInput;

    const n1 = std.fmt.parseFloat(f64, n1_str) catch return error.InvalidInput;
    const n2 = std.fmt.parseFloat(f64, n2_str) catch return error.InvalidInput;

    return .{ .n1 = n1, .op = op_str[0], .n2 = n2 };
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
        '+' => try stdout.print("Result: {}\n", .{add(expr.n1, expr.n2)}),
        '-' => try stdout.print("Result: {}\n", .{subtract(expr.n1, expr.n2)}),
        '*' => try stdout.print("Result: {}\n", .{multiply(expr.n1, expr.n2)}),
        '/' => {
            if (expr.n2 == 0.0) {
                try stdout.print("Error: Division by zero.\n", .{});
            } else {
                try stdout.print("Result: {}\n", .{divide(expr.n1, expr.n2)});
            }
        },
        else => try stdout.print("Invalid operation. Supported operations: +, -, *, /\n", .{}),
    }

    try stdout.flush();
}
