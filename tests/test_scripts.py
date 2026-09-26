"""Exercise file operations in temporary directories without touching live dotfiles."""

import os
from pathlib import Path
import shutil
import stat
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
PLUGIN_NAMES = ("zellij_forgot.wasm", "zjstatus.wasm")
OLD_WASM = b"\x00asm\x01\x00\x00\x00\x00\x04\x03old"
NEW_WASM = b"\x00asm\x01\x00\x00\x00\x00\x04\x03new"


class SymlinksTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="dotfiles tests ")
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.repo = self.directory / "repo with spaces"
        scripts = self.repo / "scripts"
        scripts.mkdir(parents=True)
        for filename in ("symlinks.sh", "utils.sh"):
            shutil.copy2(ROOT / "scripts" / filename, scripts / filename)
        self.script = scripts / "symlinks.sh"
        self.config = self.repo / "symlinks.conf"
        self.source = self.repo / "config file"
        self.source.write_text("original configuration\n")
        self.target = self.directory / "installed config"
        self.config.write_text(f"{self.source}:{self.target}\n")

    def run_script(self, *arguments, shell_function=None):
        if shell_function is None:
            command = ["/bin/bash", str(self.script), *arguments]
        else:
            command = [
                "/bin/bash", "-c",
                'source "$1"\n' + shell_function,
                "test", str(self.script),
            ]
        return subprocess.run(
            command, cwd=self.directory, capture_output=True, text=True, timeout=10
        )

    def test_create_and_repeat_from_outside_repository(self):
        source_dir = self.repo / "nvim"
        source_dir.mkdir()
        directory_target = self.directory / "new parent" / "nvim"
        self.config.write_text(
            f"$(pwd)/config file:{self.target}\n"
            f"$(pwd)/nvim:{directory_target}"
        )
        for _ in range(2):
            result = self.run_script("--create")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(os.readlink(self.target), str(self.source))
            self.assertEqual(os.readlink(directory_target), str(source_dir))

    def test_existing_directory_is_preserved_without_nested_link(self):
        self.target.mkdir()
        existing = self.target / "init.lua"
        existing.write_text("user configuration")
        result = self.run_script("--create")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(list(self.target.iterdir()), [existing])
        self.assertEqual(existing.read_text(), "user configuration")

    def test_existing_file_is_preserved(self):
        self.target.write_text("user configuration")
        result = self.run_script("--create")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.target.read_text(), "user configuration")

    def test_foreign_links_are_preserved_during_create_and_delete(self):
        foreign = self.directory / "foreign config"
        self.target.symlink_to(foreign)
        for broken in (True, False):
            with self.subTest(broken=broken):
                if not broken:
                    foreign.write_text("foreign configuration")
                result = self.run_script("--create")
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(os.readlink(self.target), str(foreign))
                result = self.run_script("--delete")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(os.readlink(self.target), str(foreign))

    def test_missing_source_returns_failure(self):
        self.source.unlink()
        result = self.run_script("--create")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.target.is_symlink())
        self.assertNotIn("Created symbolic link:", result.stdout)

    def test_parent_creation_failure_is_reported(self):
        self.target.write_text("not a directory")
        self.config.write_text(f"{self.source}:{self.target}/child\n")
        result = self.run_script("--create")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("Created symbolic link:", result.stdout)
        self.assertEqual(self.target.read_text(), "not a directory")

    def test_link_command_failure_is_reported(self):
        result = self.run_script(
            shell_function="ln() { return 1; }\ncreate_symlinks"
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.target.is_symlink())
        self.assertNotIn("Created symbolic link:", result.stdout)

    def test_delete_removes_only_active_managed_links(self):
        self.target.symlink_to(self.source)
        commented = self.directory / "commented link"
        commented.symlink_to(self.source)
        indented = self.directory / "indented comment link"
        indented.symlink_to(self.source)
        regular = self.directory / "regular file"
        regular.write_text("preserve me")
        source_dir = self.repo / "directory"
        source_dir.mkdir()
        directory_link = self.directory / "directory link"
        directory_link.symlink_to(source_dir, target_is_directory=True)
        broken_source = self.repo / "missing source"
        broken = self.directory / "managed broken link"
        broken.symlink_to(broken_source)
        self.config.write_text(
            f"#{self.source}:{commented}\n"
            f"  # {self.source}:{indented}\n\n"
            f"{self.source}:{regular}\n"
            f"{self.source}:{self.target}\n"
            f"{source_dir}:{directory_link}\n"
            f"{broken_source}:{broken}"
        )
        for _ in range(2):
            result = self.run_script("--delete")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        for removed in (self.target, directory_link, broken):
            self.assertFalse(removed.is_symlink())
        self.assertTrue(commented.is_symlink())
        self.assertTrue(indented.is_symlink())
        self.assertEqual(regular.read_text(), "preserve me")
        self.assertEqual(self.source.read_text(), "original configuration\n")
        self.assertTrue(source_dir.is_dir())

    def test_delete_preserves_real_directory_and_contents(self):
        self.target.mkdir()
        nested = self.target / "settings"
        nested.write_text("keep")
        result = self.run_script("--delete")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(nested.read_text(), "keep")

    def test_delete_failure_is_reported(self):
        self.target.symlink_to(self.source)
        result = self.run_script(
            shell_function="rm() { return 1; }\ndelete_symlinks"
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(self.target.is_symlink())
        self.assertNotIn("Deleted:", result.stdout)

    def test_include_files_option_is_rejected(self):
        self.target.write_text("user configuration")
        result = self.run_script("--delete", "--include-files")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.target.read_text(), "user configuration")


# Export a shell function instead of changing PATH or making network requests.
MOCK_CURL = r'''
curl() {
    local output_file="" fail_http=false
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --output|-o) output_file=$2; shift 2 ;;
            --fail|-f) fail_http=true; shift ;;
            *) shift ;;
        esac
    done
    [ -n "$output_file" ] || return 2
    case "$DOTFILES_TEST_DOWNLOAD:${output_file##*/}" in
        http-error:*)
            if [ "$fail_http" = true ]; then return 22; fi
            printf '<html>HTTP error</html>' > "$output_file"
            return 0 ;;
        fail-first:zellij_forgot.wasm|fail-second:zjstatus.wasm)
            printf 'partial download' > "$output_file"
            return 56 ;;
        invalid-first:zellij_forgot.wasm|invalid-second:zjstatus.wasm)
            printf '<html>Not WebAssembly</html>' > "$output_file"
            return 0 ;;
    esac
    printf '\000asm\001\000\000\000\000\004\003new' > "$output_file"
}
export -f curl
/bin/bash "$1"
'''


class PluginUpdateTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="plugin tests ")
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name)
        self.plugins = self.directory / "plugins with spaces"
        self.plugins.mkdir()
        for filename in PLUGIN_NAMES:
            (self.plugins / filename).write_bytes(OLD_WASM)

    def run_update(self, mode="success", plugin_dir=None):
        environment = os.environ.copy()
        environment["ZELLIJ_CONFIG_DIR"] = str(plugin_dir or self.plugins)
        environment["DOTFILES_TEST_DOWNLOAD"] = mode
        return subprocess.run(
            ["/bin/bash", "-c", MOCK_CURL, "test", str(ROOT / "zellij/update-plugins")],
            env=environment, capture_output=True, text=True, timeout=10,
        )

    def test_successfully_replaces_both_plugins_and_cleans_staging(self):
        result = self.run_update()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("All plugins updated!", result.stdout)
        for filename in PLUGIN_NAMES:
            installed = self.plugins / filename
            self.assertEqual(installed.read_bytes(), NEW_WASM)
            self.assertEqual(stat.S_IMODE(installed.stat().st_mode), 0o644)
        self.assertEqual(sorted(p.name for p in self.plugins.iterdir()), sorted(PLUGIN_NAMES))

    def test_failed_downloads_preserve_both_installed_plugins(self):
        for mode in ("http-error", "fail-first", "fail-second", "invalid-first", "invalid-second"):
            with self.subTest(mode=mode):
                result = self.run_update(mode)
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn("All plugins updated!", result.stdout)
                for filename in PLUGIN_NAMES:
                    self.assertEqual((self.plugins / filename).read_bytes(), OLD_WASM)
                self.assertEqual(sorted(p.name for p in self.plugins.iterdir()), sorted(PLUGIN_NAMES))

    def test_updates_through_symlinked_config_directory(self):
        linked = self.directory / "linked config"
        linked.symlink_to(self.plugins, target_is_directory=True)
        result = self.run_update(plugin_dir=linked)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(linked.is_symlink())
        for filename in PLUGIN_NAMES:
            self.assertEqual((self.plugins / filename).read_bytes(), NEW_WASM)

    def test_directory_conflict_preserves_other_plugin(self):
        conflict = self.plugins / "zjstatus.wasm"
        conflict.unlink()
        conflict.mkdir()
        result = self.run_update()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.plugins / "zellij_forgot.wasm").read_bytes(), OLD_WASM)
        self.assertEqual(list(conflict.iterdir()), [])
        self.assertFalse(list(self.plugins.glob(".plugin-update.*")))


if __name__ == "__main__":
    unittest.main()
