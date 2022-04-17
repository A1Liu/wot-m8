const std = @import("std");
const Arch = std.Target.Cpu.Arch;

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    var target = b.standardTargetOptions(.{});

    // I cannot get things to work on macbook M1 without doing this. Also,
    // initializing threadlocal doesn't really work on MacOS it seems.
    target.cpu_arch = Arch.x86_64;

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addSharedLibrary("binary", "src/main.zig", b.version(0, 0, 0));
    lib.addPackagePath("liu", "liu/lib.zig");
    lib.setBuildMode(mode);
    lib.setTarget(.{ .cpu_arch = .wasm32, .os_tag = .freestanding });
    lib.install();

    b.default_step.dependOn(&lib.step);
}
