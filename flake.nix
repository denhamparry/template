{
  description = "Claude Code project template — reproducible dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # TODO(#54): Remove when upstream pre-commit is available from
        # cache.nixos.org on aarch64-darwin without source-built .NET inputs.
        preCommitOverlay = _final: prev: {
          pre-commit =
            let
              packagePath = "${nixpkgs.outPath}/pkgs/by-name/pr/pre-commit/package.nix";
            in
            if builtins.pathExists packagePath
              && builtins.hasAttr "dotnetCorePackages" (builtins.functionArgs (import packagePath))
            then
              (prev.pre-commit.override {
                dotnetCorePackages = prev.dotnetCorePackages // {
                  sdk_8_0-source = prev.dotnetCorePackages.sdk_8_0-source.overrideAttrs (old: {
                    meta = old.meta // {
                      platforms = [ ];
                    };
                  });
                };
              }).overridePythonAttrs
                (_: {
                  doCheck = false;
                  doInstallCheck = false;
                  # pytest-check-hook runs pytest even when doCheck is false.
                  dontUsePytestCheck = true;
                })
            else
              prev.pre-commit;
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ preCommitOverlay ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            # Pre-commit hook runner
            pkgs.pre-commit

            # Node.js runtime (prettier, markdownlint)
            pkgs.nodejs

            # Standalone CLI tools (also available via pre-commit hooks)
            pkgs.prettier
            pkgs.markdownlint-cli
            pkgs.shellcheck
            pkgs.gitleaks

            # GitHub CLI (required by workflow commands)
            pkgs.gh
          ];

          shellHook = ''
            echo "dev shell"
            echo "  pre-commit:    $(pre-commit --version)"
            echo "  node:          $(node --version)"
            echo "  prettier:      $(prettier --version)"
            echo "  markdownlint:  $(markdownlint --version)"
            echo "  shellcheck:    $(shellcheck --version | head -2 | tail -1)"
            echo "  gitleaks:      $(gitleaks version)"
            echo "  gh:            $(gh --version | head -1)"
          '';
        };
      }
    );
}
