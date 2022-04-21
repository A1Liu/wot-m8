const std = @import("std");
const liu = @import("liu");

const debug = std.log.debug;
const info = std.log.info;
const err = std.log.err;

const ArrayList = std.ArrayListUnmanaged;
const HashMap = std.AutoArrayHashMapUnmanaged;

pub const FileDb = struct {
    const Self = @This();

    const File = struct {
        name: []const u8,
        text: []const u8,
    };

    arena: liu.Bump,
    files: ArrayList(File), // uses arena, because it never really resizes
    by_name: HashMap([]const u8, usize), // uses page allocator

    pub fn init(size: usize) Self {
        return Self{
            .arena = liu.Bump.init(size, liu.Pages),
            .files = ArrayList(File).init(),
            .by_name = HashMap([]const u8, usize).init(),
        };
    }

    pub fn deinit(self: *Self) void {
        self.by_name.deinit(self.arena.alloc);
        self.arena.deinit();
    }

    pub fn addFile(self: *Self, name: []const u8, text: []const u8) u32 {
        _ = self;
        _ = name;
        _ = text;
    }
};

// uses page allocator
pub const Symbols = struct {
    names: ArrayList([]const u8),
    to_symbol: HashMap([]const u8, usize),
};
