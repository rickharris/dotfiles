{ pkgs, ... }: {
  home.stateVersion = "24.11";

  # CLI packages — replaces brew formulae without dedicated home-manager modules
  home.packages = with pkgs; [
    ast-grep
    eza
    fd
    gnused
    jq
    ripgrep
    shfmt
    tree-sitter
    wget
  ];
}
