const std = @import("std");
const liu = @import("liu");

const debug = std.log.debug;
const info = std.log.info;
const err = std.log.err;

const ArrayList = std.ArrayListUnmanaged;
const StringMap = std.StringHashMapUnmanaged;

pub const FileDb = struct {
    const Self = @This();

    const File = struct {
        name: []const u8,
        text: []const u8,
    };

    arena: liu.Bump,
    files: ArrayList(File), // uses page allocator
    by_name: StringMap(usize), // uses page allocator

    names: ArrayList([]const u8), // use page allocator
    to_symbol: StringMap(usize), // use page allocator

    pub fn init(size: usize) Self {
        return Self{
            .arena = liu.Bump.init(size, liu.Pages),
            .files = ArrayList(File){},
            .by_name = StringMap(usize){},
            .names = ArrayList([]const u8){},
            .to_symbol = StringMap(usize){},
        };
    }

    pub fn deinit(self: *Self) void {
        self.by_name.deinit(self.arena.alloc);
        self.names.deinit(self.arena.alloc);
        self.to_symbol.deinit(self.arena.alloc);
        self.arena.deinit();
    }

    pub fn clearAndResize(self: *Self, new_file_count: usize, new_size: usize) void {
        _ = new_file_count;
        _ = self;
        _ = new_size;
    }

    // probably unnecessary, caller can just allocate in arena directly
    pub fn addString(self: *Self, name: []const u8) []const u8 {
        const name_arena = self.arena.alloc(u8, name.len);

        std.mem.copy(u8, name_arena, name);

        return name_arena;
    }

    pub fn addFile(self: *Self, name: []const u8, text: []const u8) u32 {
        _ = self;
        _ = name;
        _ = text;
    }
};
