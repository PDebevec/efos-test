const std = @import("std");

fn sortValues(array: []i32) void {
    var j: usize = 0;

    // insertion sort
    for (array[1..], 1..array.len) |val, i| {
        j = i;

        // premikamo vrednosti na levi v desno, dokler so manjše od trenutne vrednosti
        while (j > 0 and array[j - 1] < val) : (j -= 1) {
            array[j] = array[j - 1];
        }
        array[j] = val;
    }
}

fn writeToFile(allocator: *const std.mem.Allocator, array: []const i32, fileName: []const u8, append: bool) !void {
    // če dodajamo datoteki jo samo odpremo drugače ustvarimo novo
    const file = if (append) try std.fs.cwd().openFile(fileName, .{ .mode = std.fs.File.OpenMode.write_only }) else try std.fs.cwd().createFile(fileName, .{});
    defer file.close();

    if (append) { // če dodajamo v datoteko se moremo pomakniti na konec datoteke
        try file.seekTo(try file.getEndPos());
    }

    //najprej vpišemo prvo nato vse druge zato da nimamo na koncu ali začetku dodatnega podpičja
    try file.writeAll(try std.fmt.allocPrint(allocator.*, "{d}", .{array[0]}));
    for (array[1..]) |value| {
        try file.writeAll(try std.fmt.allocPrint(allocator.*, ";{d}", .{value}));
    }

    try file.writeAll("\n"); // na koncu dodamo new line character
}

fn readFromUser(allocator: *const std.mem.Allocator, array: *[10]i32) !void {
    const ioIn = std.io.getStdIn().reader();
    const buf: []u8 = try allocator.alloc(u8, 128);

    var i: usize = 0;
    while (i < 10) {
        std.debug.print("st {d}: ", .{i + 1});
        const read = try ioIn.readUntilDelimiter(buf, '\n');

        // preverimo ali je vnesena vrednost veljaven int drugače se sproži napaki ki jo ulovimo in nadaljujemo loop
        const int: i32 = std.fmt.parseInt(i32, read[0 .. read.len - 1], 10) catch continue;

        array[i] = int;
        i += 1;
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var numbers = [8]i32{ 8, 2, 17, 3, 12, 1, 8, 7 }; // podane številke v tabeli

    std.debug.print("{any}\n", .{numbers});
    sortValues(&numbers); //najprej sortiramo
    std.debug.print("{any}\n", .{numbers});
    //std.mem.sort(i32, &numbers, {}, std.sort.desc(i32));

    // shranimo v datoteko
    writeToFile(&allocator, &numbers, "rezultat.txt", false) catch |err| {
        std.debug.print("Error writing to file: {any}", .{err});
        return;
    };

    var array = [10]i32{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }; // ustvarimo tabelo

    // beremo in shranimo podane vrednosti
    readFromUser(&allocator, &array) catch |err| {
        std.debug.print("Error reading from user: {any}", .{err});
        return;
    };

    std.debug.print("{any}\n", .{array});
    sortValues(&array);
    std.debug.print("{any}\n", .{array});
    //std.mem.sort(i32, &array, {}, std.sort.desc(i32));

    writeToFile(&allocator, &array, "rezultat.txt", true) catch |err| {
        std.debug.print("error writing to file: {any}", .{err});
        return;
    };
}
