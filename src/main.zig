const std = @import("std");
const liu = @import("liu");

const assert = std.debug.assert;
const cast = std.math.cast;

// we'll export this to JS-land
export fn add(a: i32, b: i32) i32 {
    // const log = "happy happy joy joy";
    // console_log_ex(log, log.len);
    return a + b + 4;
}
