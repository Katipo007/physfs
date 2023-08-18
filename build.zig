const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const option_ZIP_support = b.option(bool, "PHYSFS_ARCHIVE_ZIP", "Enable ZIP support") orelse true;
    const option_7zip_support = b.option(bool, "PHYSFS_ARCHIVE_7Z", "Enable 7zip support") orelse true;
    const option_GRP_support = b.option(bool, "PHYSFS_ARCHIVE_GRP", "Enable Build Engine GRP support") orelse false;
    const option_WAD_support = b.option(bool, "PHYSFS_ARCHIVE_WAD", "Enable Doom WAD support") orelse false;
    const option_CSM_support = b.option(bool, "PHYSFS_ARCHIVE_CSM", "Enable Chasm: The Rift CSM.BIN support") orelse false;
    const option_HOG_support = b.option(bool, "PHYSFS_ARCHIVE_HOG", "Enable Descent I/II HOG support") orelse false;
    const option_MVL_support = b.option(bool, "PHYSFS_ARCHIVE_MVL", "Enable Descent I/II MVL support") orelse false;
    const option_QPAK_support = b.option(bool, "PHYSFS_ARCHIVE_QPAK", "Enable Quake I/II QPAK support") orelse false;
    const option_SLB_support = b.option(bool, "PHYSFS_ARCHIVE_SLB", "Enable I-War / Independence War SLB support") orelse false;
    const option_VDF_support = b.option(bool, "PHYSFS_ARCHIVE_VDF", "Enable Gothic I/II VDF archive support") orelse false;
    const option_ISO9660_support = b.option(bool, "PHYSFS_ARCHIVE_ISO9660", "Enable ISO9660 support") orelse true;

    const common_cflags = .{
        "-Wall",
    };

    const common_sources = .{
        "src/physfs.c",
        "src/physfs_byteorder.c",
        "src/physfs_unicode.c",
        "src/physfs_platform_os2.c",
        "src/physfs_platform_qnx.c",
        "src/physfs_archiver_dir.c",
        "src/physfs_archiver_unpacked.c",
        "src/physfs_archiver_grp.c",
        "src/physfs_archiver_hog.c",
        "src/physfs_archiver_7z.c",
        "src/physfs_archiver_mvl.c",
        "src/physfs_archiver_qpak.c",
        "src/physfs_archiver_wad.c",
        "src/physfs_archiver_csm.c",
        "src/physfs_archiver_zip.c",
        "src/physfs_archiver_slb.c",
        "src/physfs_archiver_iso9660.c",
        "src/physfs_archiver_vdf.c",
    };

    const windows_sources = .{
        "src/physfs_platform_windows.c",
    };

    const macos_sources = .{
        "src/physfs_platform_posix.c",
        "src/physfs_platform_apple.m",
    };

    const linux_sources = .{
        "src/physfs_platform_unix.c",
    };

    const lib_physfs = b.addStaticLibrary(.{
        .name = "physfs",
        .target = target,
        .optimize = optimize,
    });
    lib_physfs.addIncludePath(.{ .path = "src" });
    lib_physfs.linkLibC();
    lib_physfs.defineCMacro("PHYSFS_STATIC", null);
    lib_physfs.defineCMacro("PHYSFS_SUPPORTS_ZIP", if (option_ZIP_support) "1" else "0");
    lib_physfs.defineCMacro("PHYSFS_SUPPORTS_7Z", if (option_7zip_support) "1" else "0");
    lib_physfs.defineCMacro("PHYSFS_SUPPORTS_GRP", if (option_GRP_support) "1" else "0");
    lib_physfs.defineCMacro("PHYSFS_SUPPORTS_WAD", if (option_WAD_support) "1" else "0");
    lib_physfs.defineCMacro("PHYSFS_SUPPORTS_CSM", if (option_CSM_support) "1" else "0");
    lib_physfs.defineCMacro("PHYSFS_SUPPORTS_HOG", if (option_HOG_support) "1" else "0");
    lib_physfs.defineCMacro("PHYSFS_SUPPORTS_MVL", if (option_MVL_support) "1" else "0");
    lib_physfs.defineCMacro("PHYSFS_SUPPORTS_QPAK", if (option_QPAK_support) "1" else "0");
    lib_physfs.defineCMacro("PHYSFS_SUPPORTS_SLB", if (option_SLB_support) "1" else "0");
    lib_physfs.defineCMacro("PHYSFS_SUPPORTS_VDF", if (option_VDF_support) "1" else "0");
    lib_physfs.defineCMacro("PHYSFS_SUPPORTS_ISO9660", if (option_ISO9660_support) "1" else "0");

    switch (lib_physfs.target_info.target.os.tag) {
        .windows => {
            lib_physfs.linkSystemLibraryName("advapi32");
            lib_physfs.linkSystemLibraryName("shell32");
            lib_physfs.addCSourceFiles(
                &(common_sources ++ windows_sources),
                &(common_cflags),
            );
        },
        .macos => {
            lib_physfs.linkSystemLibrary("-framework IOKit");
            lib_physfs.linkSystemLibrary("-framework Foundation");
            lib_physfs.addCSourceFiles(
                &(common_sources ++ macos_sources),
                &(common_cflags),
            );
        },
        else => {
            lib_physfs.linkSystemLibrary("pthread");
            lib_physfs.addCSourceFiles(
                &(common_sources ++ linux_sources),
                &(common_cflags),
            );
        },
    }
    b.installArtifact(lib_physfs);
}

pub const main_header_path = get_sdk_path() ++ "/src/physfs.h";

fn get_sdk_path() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
