const std = @import("std");
const Arch = std.Target.Cpu.Arch;
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    // I cannot get things to work on macbook M1 without doing this. Also,
    // initializing threadlocal doesn't really work on MacOS it seems.
    var target = b.standardTargetOptions(.{});
    target.cpu_arch = Arch.x86_64;

    const lib = b.addSharedLibrary("web", "src/wasm.zig", b.version(0, 0, 0));
    lib.addPackagePath("liu", "liu/lib.zig");
    lib.setBuildMode(mode);
    lib.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    lib.install();

    const exe = b.addExecutable("native", "src/main.zig");
    exe.addPackagePath("liu", "liu/lib.zig");
    exe.setBuildMode(mode);
    exe.setTarget(target);
    exe.install();

    b.default_step.dependOn(&lib.step);

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const native_step = b.step("native", "Build native version");
    native_step.dependOn(&exe.step);
}
