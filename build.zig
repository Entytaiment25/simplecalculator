const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "simplecalculator",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);

    const run_artifact = b.addRunArtifact(exe);
    run_artifact.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_artifact.step);

    if (b.args) |args| {
        run_artifact.addArgs(args);
    }

    const test_exe = b.addTest(.{
        .root_module = exe.root_module,
    });
    const run_test = b.addRunArtifact(test_exe);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_test.step);
}
