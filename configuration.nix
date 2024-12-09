#Edit this configuration file to define what should be installed on
#f your system.  Help is available in the configuration.nix(5) man page
#a and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, inputs, lib, ... }:

# let
#   unstable = import <nixos-unstable> { config = { allowUnfree = true;}; };
#     # (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/unstable)
#     # reuse the current configuration
# in

let

  # my-kak-tree-sitter = with pkgs; stdenv.mkDerivation rec {
  #   name = "kak-tree-sitter";
  #   src = fetchGit {
  #     url = "https://git.sr.ht/~hadronized/kak-tree-sitter";
  #   };
  # };

  # configure-gtk = pkgs.writeTextFile {
  #     name = "configure-gtk";
  #     destination = "/bin/configure-gtk";
  #     executable = true;
  #     text = let
  #       schema = pkgs.gsettings-desktop-schemas;
  #       datadir = "${schema}/share/gsettings-schemas/${schema.name}";
  #     in ''
  #       gnome_schema=org.gnome.desktop.interface
  #       gsettings set $gnome_schema gtk-theme 'Dracula'
  #     '';
  #   };

  myneovim = pkgs.neovim.overrideAttrs
      (old: {
        generatedWrapperArgs = old.generatedWrapperArgs or [ ] ++ [
          "--prefix"
          "PATH"
          ":"
          (lib.makeBinPath [
            pkgs.ripgrep
            pkgs.gcc
            pkgs.nodejs
            pkgs.nil
            pkgs.nixd
            pkgs.pyright
            pkgs.lua-language-server
            pkgs.stylua
            pkgs.deadnix
            pkgs.statix
            pkgs.fd
          ])
        ];
      });
in
{
  # nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"]; # not sure if this is necessary (doesn't seem to work)

  imports = [
    ./hardware-configuration.nix
    # /etc/nixos/qtile.nix
  ];


  # enable flakes and stuff
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # get latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.loader.grub.useOSProber = true; # check if this works

  # stuff for OBS
  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  boot.kernelModules = ["v4l2loopback"];
  security.polkit.enable = true;
  # hardware.opengl.enable = true;
  hardware.graphics.enable = true; # same but for new version


  networking.hostName = "bapanada"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking (BTW also enables wireless support afaik)
  networking.networkmanager.enable = true;

  # maybe fix dumb issue where I'd constantly have to type my password
  security.pam.services.sddm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_CA.UTF-8";
    LC_IDENTIFICATION = "en_CA.UTF-8";
    LC_MEASUREMENT = "en_CA.UTF-8";
    LC_MONETARY = "en_CA.UTF-8";
    LC_NAME = "en_CA.UTF-8";
    LC_NUMERIC = "en_CA.UTF-8";
    LC_PAPER = "en_CA.UTF-8";
    LC_TELEPHONE = "en_CA.UTF-8";
    LC_TIME = "en_CA.UTF-8";
  };

  # # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Budgie Desktop environment.
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.desktopManager.budgie.enable = true;
  # services.xserver.desktopManager.xfce.enable = true; # maybe enable to fix thunar issues and stuff
  # services.xserver.windowManager.qtile.enable = true;
  # services.xserver.windowManager.xmonad = {
  #   enable = true;
  #   enableContribAndExtras = true;
  # };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Greeter
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };


  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
  };

  programs.file-roller.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  
  programs.zsh = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      vimdiff = "nvim -d";
    };
    # export is just for kakoune treesitter: export PATH=$HOME/.cargo/bin:$PATH
    promptInit=''
      function y() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
          yazi "$@" --cwd-file="$tmp"
          if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
              builtin cd -- "$cwd"
          fi
          rm -f -- "$tmp"
      } 
    	eval "$(zoxide init zsh)"
    '';

    ohMyZsh = {
      enable = true;
      theme = "agnoster";
      # theme = "half-life";
      plugins = [
        "git"
        "command-not-found"
        "history-substring-search"
        # "zoxide"
      ];
    };
  };

  programs.tmux = {
    enable = true;
  };


  # programs.yazi = {
  #   enable = true;
  # };


  # programs.direnv = {
  #   enable = true;
  # };

  programs.nix-ld.enable=true;
  programs.nix-ld.libraries = with pkgs; [
    # add missing libraries here
  ];

# syncthing
  services.syncthing = {
    enable = true;
    user = "josh";
    dataDir = "/home/josh/syncthing";    # Default folder for new synced folders
    configDir = "/home/josh/syncthing";   # Folder for Syncthing's settings and keys
  };


  environment.shells = with pkgs; [zsh];
  users.defaultUserShell = pkgs.zsh;
  environment.variables = {
    EDITOR = "kak";
    VISUAL = "kak";
  };

  environment.sessionVariables = rec {
    NIXOS_OZONE_WL = "1";
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";

    # Not officially in the specification
    XDG_BIN_HOME    = "$HOME/.local/bin";

    PATH = [
      "${XDG_BIN_HOME}"
    ];
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = ["gtk"];
      hyprland.default = ["gtk" "hyprland"];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  services.printing = {
    enable = true;
    drivers = [
      pkgs.cups-pdf-to-pdf
    ];
  };

  # Enable sound with pipewire.
  # sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # garbage collection settings
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  boot.loader.grub.configurationLimit = 30;


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true; # old way
  services.libinput.enable = true;
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      iosevka
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      font-awesome
      powerline-fonts
      powerline-symbols
      nerd-fonts.symbols-only
      # (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
      proggyfonts
      cozette
      luculent
    ];
    fontconfig= {
      enable = true;
      # antialias = true;
      hinting.enable = true;
      hinting.autohint = true;
      # subpixel.rgba = true;
      subpixel.lcdfilter = "default";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.josh = {
    isNormalUser = true;
    description = "Josh Martin";
    extraGroups = ["networkmanager" "wheel" "audio" "video" "input"];
    shell = pkgs.zsh;

    packages = with pkgs; [
      firefox
      jetbrains.idea-community
      # discord
      discord-canary
      steam
      # gimp
      obsidian
      # golly
      exercism
      tor-browser
      protonvpn-gui
      qownnotes
      # mars-mips
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    # stuff I need
    # neovim
    myneovim

    # (import /home/josh/.config/my-hello.nix)

    ripgrep
    nil
    nixd
    nixfmt-rfc-style # nix formatter
    alejandra # nix formatter
    lua-language-server
    # zls
    pyright
    helix

    # # have decided to use plug.kak instead
    # (kakoune.override {
    #   plugins = with pkgs.kakounePlugins; [
    #     fzf-kak
    #     kakoune-lsp
    #     smarttab-kak
    #   ];
    # })

    kakoune
    kak-lsp
    kak-tree-sitter

    zed-editor
    emacs #doom emacs needs: git, ripgrep; wants: fd, coreutils, clang

    wget
    curl
    git
    lazygit
    yazi
    fd # for yazi
    dragon
    ranger # file manager
    # stuff for ranger
    atool
    unzip
    unrar

    lf # file manager

    starship
    zoxide
    fzf # not sure if I need this
    alacritty # terminal
    wezterm
    kitty
    cmatrix # Take The Purple Pill
    fuzzel # app launcher
    pavucontrol
    helvum # audio interface
    imv # image viewer
    stow
    hstr
    qbittorrent

    qdirstat # disk view utility

    # yuzu
    # citra

    # peazip # archive manager
    pkgs.file-roller
    lxqt.lxqt-policykit

    killall
    imagemagick # CL image editing tools
    btop
    s-tui
    stress
    # popsicle

    mpd
    mpv

    pulseaudio # only needed for commands I think
    # steam-run
    prismlauncher

    # godotBin

    # hyprland stuff
    hyprcursor
    hypridle
    hyprlock
    hyprpicker
    # bibata-cursors
    waybar
    dunst
    networkmanagerapplet
    grim #screenshot
    slurp #select
    wl-clipboard
    libnotify
    brightnessctl
    swww #screenshare
    cups-pdf-to-pdf # print to pdf utility?

    # obs-studio
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
