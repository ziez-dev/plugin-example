# ziez-plugin-example

Example plugin scaffold for [ziez](https://github.com/ziez-dev/ziez) — demonstrates both stateless and stateful middleware patterns.

## Requirements

- Zig 0.16.0+

## Installation

In `build.zig.zon`:

```zig
.dependencies = .{
    .ziez = .{
        .url = "https://github.com/ziez-dev/ziez/archive/refs/tags/v0.0.1.tar.gz",
        .hash = "ziez-0.0.1-zH20Gh1jAwADi2a_88hnfVHclInMW1YPLF_y7SS7CJ5Y",
    },
    .@"ziez-plugin-example" = .{
        .url = "https://github.com/ziez-dev/plugin-example/archive/refs/tags/v0.0.1.tar.gz",
        .hash = "1220b1fe03d61a1cc83ee28e918e1a2e4f0e0d6d1e23844e0c0e28194a8bbbe9d2e8",
    },
},
```

In `build.zig`:

```zig
const plugin_dep = b.dependency("ziez-plugin-example", .{
    .target = target,
    .optimize = optimize,
});
exe_mod.addImport("ziez_my_plugin", plugin_dep.module("ziez-my-plugin"));
```

## Quick Start

```zig
const std = @import("std");
const ziez = @import("ziez");
const my_plugin = @import("ziez_my_plugin");
const stateful = @import("ziez_my_plugin").stateful;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var threaded = std.Io.Threaded.init_single_threaded;
    const io = threaded.io();

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

    try app.listen(io, "0.0.0.0:3000");
}
```

## Patterns

**Stateless middleware** — Config is captured by value at comptime. No heap allocation. Best for simple config-driven middleware.

**Stateful middleware** — Heap-allocated state that persists across requests. Automatically freed when `app.deinit()` is called. Best for middleware that needs mutable state (counters, caches, connection pools).

## Configuration

**Config (stateless):**

| Option | Type | Default | Description |
|---|---|---|---|
| `enabled` | `bool` | `true` | Enable/disable the middleware |

## License

MIT
