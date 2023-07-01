# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "nixos"; # Define your hostname.

  # NetworkManager
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  # BluetoothManager
  services.blueman.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp14s0.useDHCP = true;
  networking.interfaces.wlp13s0.useDHCP = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

#  # Select input method.
#  i18n.inputMethod = {
#    enabled = "fcitx5";
#    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
#  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    desktopManager.lxqt.enable = true;
    displayManager.defaultSession = "lxqt";
    # Configure keymap in X11
    layout = "us,ru,pl";
    # xkbOptions = "eurosign:e";
    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      mouse = {
        accelProfile = "flat";
      };
      touchpad = {
        accelProfile = "flat";
        accelSpeed = "1.0";
        naturalScrolling = true;
      };
    };
    videoDrivers = [ "nvidia" ];
    # dpi = 96;
  };

  # Nvidia
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
    modesetting.enable = true;
    prime = {
      offload.enable = true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };

  # Enable sound.
  sound.enable = true;
  sound.mediaKeys.enable = true;

  # Hardware
  hardware = {
    bluetooth.enable = true;
    pulseaudio = {
      enable = true;
      # extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cas1no = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
    "nvidia-settings"
    "nvidia-x11"
    # "skypeforlinux"
    "steam"
    "steam-original"
    "steam-runtime"
    "unigine-valley"
    # "android-studio-stable"
    # "vscode-extension-ms-vscode-cpptools"
    # "stm32cubemx"
    "zerotierone"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    let
      nvidia-offload = writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec -a "$0" "$@"
      '';
    in
    [
      nvidia-offload
      unigine-valley
      vscodium-fhs
      tdesktop
      git
      # neovim
      wget
      firefox
      chromium
      qbittorrent
      # redshift
      krita
      smplayer
      mpv
      # playerctl
      # android-studio
      pass
      # jetbrains.pycharm-community
      gcc
      gnumake
      p7zip
      ripgrep
      # skype
      discord
      # freerdp
      # socat
      # openocd
      # stm32cubemx
      zerotierone
      # gcc-arm-embedded
      anki
      xclip
      djview
      ardour
      lmms
      koreader
      wine64
      wineWowPackages.full
      winetricks
    ];

  programs.steam.enable = true;

  programs.neovim = let unstable = import <nixos-unstable> {};
      in {
        enable = true;
        defaultEditor = true;
        package = unstable.neovim-unwrapped;
      };

  fonts.fonts = with pkgs; [
    jetbrains-mono
    noto-fonts-cjk
    google-fonts
  ];
  # fonts.fontconfig.hinting.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "6ab565387abbe732" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

