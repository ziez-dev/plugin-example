const std = @import("std");
const ziez = @import("ziez");
const my_plugin = @import("ziez_my_plugin");
const stateful = @import("ziez_my_plugin").stateful;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var app = ziez.init(allocator);
    defer app.deinit();

    // Stateless middleware — config passed by value
    app.use(my_plugin.middleware(.{ .enabled = true }));

    // Stateful middleware — heap-allocated, auto-freed at app.deinit()
    app.use(stateful.middleware(.{ .value = 42 }));

    app.get("/", struct {
        fn h(_: *ziez.Request, res: *ziez.Response) !void {
            res.json(.{ .ok = true });
        }
    }.h);

    try app.listen("0.0.0.0:3000");
}
