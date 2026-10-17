{
  description = "Nix package for cavemem";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    set-and-setting.url = "github:pr0d1r2/set-and-setting";
    set-and-setting.inputs.nixpkgs-lock.follows = "nixpkgs-lock";
  };

  outputs =
    {
      self,
      nixpkgs,
      set-and-setting,
      ...
    }:
    set-and-setting.lib.mkConsumerFlake {
      inherit self nixpkgs set-and-setting;
      fragments = [
        "base"
        "nix"
        "shell"
        "ascii"
        "markdown"
        "yaml"
      ];
      src = ./.;
      extraPackages = pkgs: {
        cavemem = import ./cavemem.nix { inherit pkgs; };
        default = import ./cavemem.nix { inherit pkgs; };
      };
      extraChecks = pkgs: {
        cavemem-package =
          assert builtins.hasAttr "default" self.packages.${pkgs.system};
          assert builtins.hasAttr "cavemem" self.packages.${pkgs.system};
          pkgs.runCommand "cavemem-package-output-check" { } "touch $out";
      };
    };
}
