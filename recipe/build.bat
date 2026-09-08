@echo on

:: crates\workspace\build.rs embeds these archives; it exits 1 with an explanatory
:: message if they are missing, but check here so a source layout change reads as a
:: recipe problem rather than a compile failure.
:: `dir` rejects a wildcard in a directory component, so the standard library archives in
:: .cache\sysml-stdlib-kpar-<version>\ cannot be matched by pattern. `dir /s` recurses
:: instead, covering them and the two Elan8 bundles in .cache itself with one check.
dir /s /b "%SRC_DIR%\.cache\*.kpar" > nul || exit 1

:: rust-toolchain.toml pins an exact channel for upstream CI. It is a rustup feature and
:: is ignored by the bare cargo/rustc that the conda-forge rust compiler provides, so the
:: packaged toolchain is used regardless. Removed anyway to keep that explicit.
del /f /q rust-toolchain.toml

set CARGO_PROFILE_RELEASE_STRIP=symbols

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if %ERRORLEVEL% neq 0 exit 1

:: One binary, `spec42` from crates\server: the language server and CLI, and the only
:: artifact upstream publishes. Up to 0.50.0 crates\kpar also built a `kpar-pack` binary,
:: installed here as well; 0.51.0 turned that crate into a library only, so installing it
:: now fails with "no packages found with binaries or examples". Its packing function is
:: reachable as `spec42 bundle`.
::
:: Installed under %PREFIX% so it lands in bin, matching build.sh. conda puts
:: %PREFIX%\bin on PATH when activating on Windows, and rattler-build's
:: package_contents bin check globs bin\ as well as Library\bin\ and Scripts\.
cargo install --locked --no-track --root "%PREFIX%" --path crates\server
if %ERRORLEVEL% neq 0 exit 1
