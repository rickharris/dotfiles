{ ... }:
{
  nix.enable = false;
  system.stateVersion = 6;
  system.primaryUser = "rick";
  users.users.rick.home = "/Users/rick";
}
