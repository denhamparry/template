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
        pkgs = nixpkgs.legacyPackages.${system};
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
