{ user, ... }:

let
  home           = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";
  xdg_dataHome   = "${home}/.local/share";
  xdg_stateHome  = "${home}/.local/state"; in
{

  "${xdg_configHome}/polybar/bin/check-nixos-updates.sh" = {
    executable = true;
    text = ''
      #!/bin/sh

      /run/current-system/sw/bin/git -C ~/.local/share/src/nixpkgs fetch upstream master
      UPDATES=$(/run/current-system/sw/bin/git -C ~/.local/share/src/nixpkgs rev-list origin/master..upstream/master --count 2>/dev/null);
      /run/current-system/sw/bin/echo " $UPDATES"; # Extra space for presentation with icon
      /run/current-system/sw/bin/sleep 1800;
    '';
  };

  "${xdg_configHome}/polybar/bin/search-nixos-updates.sh" = {
    executable = true;
    text = ''
      #!/bin/sh

      /etc/profiles/per-user/${user}/bin/google-chrome-stable --new-window "https://search.nixos.org/packages"
    '';
  };

}
