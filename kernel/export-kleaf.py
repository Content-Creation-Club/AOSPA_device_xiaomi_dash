#!/usr/bin/env python3
# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

import argparse
import os
from pathlib import Path
import subprocess


def profile_paths(workspace, profile):
    outputs = workspace / "bazel-bin/kernel_device_modules-6.6"
    strict = profile != "normal"
    core_target = "kernel_strict.user" if strict else "mgk_64_k66_kernel_aarch64.user"
    bootstrap_target = "ufs_wlun_bootstrap_strict.user" if strict else "ufs_wlun_bootstrap.user"
    core = outputs / core_target
    config = outputs / (core_target + "_config/out_dir/.config")
    if profile == "official":
        core = workspace / "out/bazel/repositories/dash_official_gki/android15-6.6-2026-10_r3"
        config = core / ".config"
    return outputs, core, config, outputs / bootstrap_target, core_target, bootstrap_target


def read_list(path):
    return [line.split("#", 1)[0].strip() for line in path.read_text().splitlines()
            if line.split("#", 1)[0].strip()]


def link(source, target):
    source = source.resolve(strict=True)
    if not target.is_symlink() or os.readlink(target) != str(source):
        target.unlink(missing_ok=True)
        target.symlink_to(source)
    stat = source.stat()
    # Ninja stats output symlinks themselves, not the shared file they expose.
    os.utime(target, ns=(stat.st_atime_ns, stat.st_mtime_ns), follow_symlinks=False)


def write_text(path, text):
    if not path.is_file() or path.read_text() != text:
        path.write_text(text)


def export(workspace, device, out, profile, system_dlkm):
    outputs, core, config, bootstrap, _, _ = profile_paths(workspace, profile)
    partitions = {}
    installed = {}
    for partition, load_name in [("vendor_ramdisk", "platform"), ("vendor_dlkm", "vendor_dlkm")]:
        modules = {}
        install = []
        for path in read_list(device / ("modules." + partition)):
            if path.startswith("@core/"):
                source = core / path.removeprefix("@core/")
            elif path.startswith("@bootstrap/"):
                source = bootstrap / path.removeprefix("@bootstrap/")
            else:
                source = outputs / path
            name = source.name
            source = source.resolve(strict=True)
            if name in modules and modules[name] != source:
                raise ValueError(f"conflicting module sources for {name}")
            modules[name] = source
            install.append(name)
        load = read_list(device / ("modules.load." + load_name))
        if partition == "vendor_ramdisk":
            load.insert(0, "ufs_wlun_bootstrap.ko")
        if not set(load) <= set(install):
            raise ValueError(f"{partition}: unmapped load entries: {set(load) - set(install)}")
        installed[partition] = set(install)
        partitions[partition] = modules
    if system_dlkm:
        modules = {}
        load = read_list(device / "modules.load.system_dlkm")
        for name in load:
            # Official GKI omits TLS; use this build's audited vendor-KMI module.
            source = outputs / "kernel_strict.user/tls.ko" if profile == "official" and name == "tls.ko" else core / name
            source = source.resolve(strict=True)
            if name in modules and modules[name] != source:
                raise ValueError(f"conflicting module sources for {name}")
            modules[name] = source
        partitions["system_dlkm"] = modules
    recovery = ["ufs_wlun_bootstrap.ko"] + read_list(device / "modules.load.recovery")
    ramdisk_install = installed["vendor_ramdisk"]
    if not set(recovery) <= ramdisk_install:
        raise ValueError(f"recovery: unmapped load entries: {set(recovery) - ramdisk_install}")

    out.mkdir(parents=True, exist_ok=True)
    for partition, modules in partitions.items():
        module_dir = out / "modules" / partition
        module_dir.mkdir(parents=True, exist_ok=True)
        for name, source in modules.items():
            link(source, module_dir / name)
    link(core / "Image.lz4", out / "Image.lz4")
    link(config, out / ".config")
    link(outputs / "mgk_64_k66_merged_uapi_headers.user/kernel-uapi-headers.tar.gz",
         out / "kernel-uapi-headers.tar.gz")
    write_text(out / "modules.load.recovery", "\n".join(recovery) + "\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--profile", choices=["normal", "strict", "official"], required=True)
    parser.add_argument("--system-dlkm", choices=["true", "false"], required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    device = Path(__file__).resolve().parent
    workspace = Path("kernel/xiaomi/dash").resolve(strict=True)
    _, _, _, _, core_target, bootstrap_target = profile_paths(workspace, args.profile)
    common_targets = ["mgk_64_k66_customer_modules_install.user", "mgk_64_k66_merged_uapi_headers.user"]

    def build(targets, check):
        subprocess.run(["bash", str(device / "build-kleaf.sh"),
                        "--//build/kernel/kleaf:kmi_symbol_list_violations_check=" + check,
                        *("//kernel_device_modules-6.6:" + target for target in targets)], check=True)

    if args.profile == "normal":
        build([core_target, *common_targets, bootstrap_target], "false")
    else:
        # MTK modules retain their native build; enforce GKI checks on the selected core.
        build(common_targets, "false")
        build([core_target, bootstrap_target], "true")
    if args.profile == "official":
        subprocess.run(["bash", str(device / "fetch-official-gki.sh")], check=True)
    export(workspace, device, args.out, args.profile, args.system_dlkm == "true")


if __name__ == "__main__":
    main()
