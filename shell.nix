{
  pkgsWith37 ? import (builtins.fetchTarball {
    # Branch: nixos-22.11
    url = "https://github.com/NixOS/nixpkgs/archive/96e18717904dfedcd884541e5a92bf9ff632cf39.tar.gz";
    sha256 = "0zw1851mia86xqxdf8jgy1c6fm5lqw4rncv7v2lwxar3vhpn6c78";
  }) {},
  python37_overlay ? self: super: { python37 = pkgsWith37.python37; },
  pkgs ? import (builtins.fetchTarball {
    # Branch: nixos-unstable
    url = "https://github.com/NixOS/nixpkgs/archive/bd645e8668ec6612439a9ee7e71f7eac4099d4f6.tar.gz";
    sha256 = "1blyn61gvvrm1gkd4cscc6sslk7z6k5lzmar12wig7ijqdvwml26";
  }) { overlays = [ python37_overlay ]; }
}:
pkgs.mkShell {
  name = "myproject-env";
  buildInputs = with pkgs; [
    python37
    python38
    python39
    python310
    python311
    python312
    poetry
  ];
  shellHook = ''
    # This is needed to keep python3.7 working while in the same nix-shell
    # as a later python (see https://github.com/NixOS/nixpkgs/issues/88711
    # for more details):
    unset _PYTHON_HOST_PLATFORM
    unset _PYTHON_SYSCONFIGDATA_NAME

    poetry env use "${pkgs.python311}/bin/python"
    poetry install --sync
    source "$(poetry env info --path)/bin/activate"
    pip install nox
  '';
}
