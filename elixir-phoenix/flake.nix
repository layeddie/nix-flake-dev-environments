{
  description = "Gleam";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        inherit (pkgs) darwin elixir inotify-tools nodejs-18_x terminal-notifier;
        inherit (pkgs.lib) optional;
        inherit (pkgs.stdenv) isDarwin isLinux;

        linuxDeps = optional isLinux
          [ inotify-tools ];
        darwinDeps = optional isDarwin
          [ terminal-notifier ] ++ (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);
      in {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = [
              elixir
              nodejs-18_x
            ] ++ linuxDeps ++ darwinDeps;

            shellHook = ''
              cat << EOF
              Entering Elixir env. Running:

              echo `${elixir}/bin/mix --version`
              echo `${elixir}/bin/iex --version`

              EOF
            '';
          };
        };
      }
    );
}
