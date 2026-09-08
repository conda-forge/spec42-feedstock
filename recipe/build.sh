#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# crates/workspace/build.rs embeds these archives; it exits 1 with an explanatory
# message if they are missing, but check here so a source layout change reads as a
# recipe problem rather than a compile failure.
ls -1 "${SRC_DIR}"/.cache/sysml-stdlib-kpar-*/*.kpar > /dev/null
ls -1 "${SRC_DIR}"/.cache/*.kpar > /dev/null

# rust-toolchain.toml pins an exact channel for upstream CI. It is a rustup feature and
# is ignored by the bare cargo/rustc that the conda-forge rust compiler provides, so the
# packaged toolchain is used regardless. Removed anyway to keep that explicit.
rm -f rust-toolchain.toml

export CARGO_PROFILE_RELEASE_STRIP=symbols

cargo-bundle-licenses \
    --format yaml \
    --output THIRDPARTY.yml

# One binary, `spec42` from crates/server: the language server and CLI, and the only
# artifact upstream publishes. Up to 0.50.0 crates/kpar also built a `kpar-pack` binary,
# installed here as well; 0.51.0 turned that crate into a library only, so installing it
# now fails with "no packages found with binaries or examples". Its packing function is
# reachable as `spec42 bundle`.
cargo install --locked --no-track --root "${PREFIX}" --path crates/server
