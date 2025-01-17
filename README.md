# Shimeji for Linux

This project is a fork of the original project by Yuki Yamada. The original README is included as [ORIGINAL_README.md](ORIGINAL_README.md) for reference. This project includes code originally licensed under the zlib license. Please see the [ORIGINAL_ZLIB_LICENSE](./ORIGINAL_ZLIB_LICENSE) for details. All new contributions to this project are licensed under the [LICENSE](./LICENSE). Please see the [`LICENSE`](./LICENSE) for more details.

Also, this project includes `Little Ghost` images and it's licenses under [hk-imgs/license](./hk-imgs/licence.txt). and [hk-imgs/originallicense](./hk-imgs/originallicense.txt), see those for reference.

## Changes

- Added a nix flake
- Added Hollow Knight shimeji images and it's licenses under [hk-shimeji](./hk-shimeji)

## Installation

### NixOS System-Wide Installation

Add to your `/etc/nixos/configuration.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    linux-shimeji.url = "github:datsfilipe/linux-shimeji";
  };
  
  outputs = { self, nixpkgs, linux-shimeji }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            linux-shimeji.packages.${pkgs.system}.default
            # Or choose a specific variant:
            # linux-shimeji.packages.${pkgs.system}.little-ghost
            # linux-shimeji.packages.${pkgs.system}.little-ghost-polite
          ];
        })
      ];
    };
  };
}
```

### Single User Installation

```bash
nix profile install github:datsfilipe/linux-shimeji
# Or for specific variants:
nix profile install github:datsfilipe/linux-shimeji#little-ghost
nix profile install github:datsfilipe/linux-shimeji#little-ghost-polite
```

### Running

After installation, launch with:
```bash
shimeji
```
