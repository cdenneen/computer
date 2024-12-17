{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [

  # App and package management
  appimage-run
  gnumake
  cmake
  home-manager

  # Media and design tools
  fontconfig
  font-manager

  # Productivity tools
  bc # old school calculator
  galculator

  # Audio tools
  pavucontrol # Pulse audio controls

  # Testing and development tools
  direnv
  postgresql
  libtool # for Emacs vterm

  # Text and terminal utilities
  feh # Manage wallpapers
  screenkey
  tree
  unixtools.ifconfig
  unixtools.netstat
  xclip # For the org-download package in Emacs

  # File and system utilities
  sqlite
  xdg-utils

  # Other utilities
  google-chrome

]
