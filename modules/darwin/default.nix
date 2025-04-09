{ pkgs, ... }: {
  # here go the darwin preferences and config items
  programs.zsh.enable = true;
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    # config.allowBroken = true;
    config = {
      allowBroken = true;
      allowUnfree = true;
    };
  };
  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  environment = {
    shells = with pkgs; [ bash zsh ];
    ##loginShell = pkgs.zsh;
    systemPackages = (import ./packages.nix { inherit pkgs; });
    pathsToLink = [ "/Applications" ];
  };
  # Setup user, packages, programs
  users.users.joel = {
    name = "joel";
    home = "/Users/joel";
  };
  nix = {
    enable = true;
    package = pkgs.nixVersions.latest;
    settings.trusted-users = [ "@admin" "joel" "joeldsouza" ];
    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  fonts.packages = with pkgs; [
    carlito
    vegur
    source-code-pro
    jetbrains-mono
    font-awesome
    corefonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
  ];

  ## services.nix-daemon.enable = true;
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    finder._FXShowPosixPathInTitle = true;
    dock.autohide = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 14;
    NSGlobalDomain.KeyRepeat = 1;
  };
  users.users.joeldsouza.home = "/Users/joeldsouza";

  #security
  security.pam.services.sudo_local.touchIdAuth = true;

  # backwards compat; don't change
  system.stateVersion = 5;
  homebrew = {
    # This is a module from nix-darwin
    # Homebrew is *installed* via the flake input nix-homebrew
    enable = true;
    onActivation = {
      cleanup = "uninstall";
      # this sucks, as the entire homebrew does. gah
      autoUpdate = true;
      upgrade = true;
    };

    global.autoUpdate = false;
    casks = pkgs.callPackage ./casks.nix { };

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      #"1password" = 1333542190;
    };

    brews = [
      {
        name = "emacs-plus@31";
        args = [ "with-dbus" "with-imagemagick" "with-mailutils" ];
      }
      "pinentry"
      "gcc"
      "libgccjit"
      "libtool"
      "zlib"
      "bzip2"
      "libjpeg"
    ];
  };

  #  osascript -e 'tell application "Finder" to make alias file to posix file "/opt/homebrew/opt/emacs-plus@29/Emacs.app" at POSIX file "/Applications"'
}
