{ pkgs, ... }: {
  # Nix configuration
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Required for nix-darwin
  system.stateVersion = 6;
}
