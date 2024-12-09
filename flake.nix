{
  description = "System Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    stable.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    ki-editor.url = "github:ki-editor/ki-editor";
  };

  outputs = { self, nixpkgs, stable, ki-editor, ...  }: {
    nixosConfigurations."bapanada" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
        modules = [
          ({ pkgs, ... } : {system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;})
          { environment.systemPackages = [ ki-editor.packages.x86_64-linux.default ]; }
          { environment.systemPackages = [ stable.legacyPackages.x86_64-linux.bibata-cursors ]; }
          ./configuration.nix
          ./nvidia.nix
      ];
    };
  };
}
