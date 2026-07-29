{
  description = "Nix flake packaging cavemem -- cross-agent persistent memory with compressed storage";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    set-and-setting.url = "github:pr0d1r2/set-and-setting";
  };

  outputs =
    {
      self,
      nixpkgs,
      set-and-setting,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      fragments = [
        "base"
        "nix"
        "shell"
        "ascii"
        "markdown"
        "yaml"
      ];
    in
    (import "${set-and-setting}/set/lib/mk-consumer-flake.nix" {
      inherit supportedSystems;
    })
      {
        inherit self nixpkgs fragments;
        inherit (set-and-setting.inputs) set-and-setting;
        src = ./.;
        extraPackages = pkgs: {
          default = import ./cavemem.nix { inherit pkgs; };
        };
        extraChecks = _pkgs: {
          public-interface = _pkgs.runCommand "public-interface-check" { } "touch $out";
        };
      };
}
