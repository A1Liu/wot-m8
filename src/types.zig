const std = @import("std");
const liu = @import("liu");

const debug = std.log.debug;
const info = std.log.info;
const err = std.log.err;

const ArrayList = std.ArrayList;
const HashMap = std.AutoArrayHashMap;

const File = struct {
    name: []const u8,
    text: []const u8,
};

pub const FileDb = struct {
    files: ArrayList(File),
    by_name: HashMap([]const u8, usize),
};

pub const Symbols = struct {
    names: ArrayList([]const u8),
    to_symbol: HashMap([]const u8, usize),
};
