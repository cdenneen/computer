{ config, pkgs, ... }:

{
  services.nix-daemon.enable = true
  nix.settings.experimental-features = "nix-command flakes";
  nix.extraOptions = ''
    extra-platforms = x86_64-linux aarch64-linux
  ''
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 1;

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "aarch64-linux";
  };


  users.users.cdenneen = {
    description = "Chris Denneen";
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/ubuntu";
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  time.timeZone = "America/New_York";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  programs.zsh.enable = true;

}
