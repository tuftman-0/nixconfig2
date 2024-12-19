{
  description = "System Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    stable.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    ki-editor.url = "github:ki-editor/ki-editor";
    ghostty = {
      url = "git+ssh://git@github.com/ghostty-org/ghostty";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, stable, ki-editor, ghostty, ...  }: {
    nixosConfigurations."bapanada" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
        modules = [
          ({ pkgs, ... } : {system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;})
          {
            environment.systemPackages = [
              ki-editor.packages.x86_64-linux.default
              stable.legacyPackages.x86_64-linux.bibata-cursors
              ghostty.packages.x86_64-linux.default
            ];
          }
          ./configuration.nix
          ./nvidia.nix
      ];
    };
  };
}
