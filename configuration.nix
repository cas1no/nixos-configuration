# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

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

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    desktopManager.lxqt.enable = true;
    displayManager.defaultSession = "lxqt";
#    displayManager.setupCommands = ''
#      # workaround for using NVIDIA Optimus without Bumblebee
#      xrandr --setprovideroutputsource modesetting NVIDIA-0
#      xrandr --auto
#    '';
    # Configure keymap in X11
    layout = "us,ru,pl";
    xkbOptions = "eurosign:e";
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
    # videoDrivers = [ "modesetting" ];
    # videoDrivers = [ "nvidia" "modesetting" ];
    videoDrivers = [ "nvidia" ];
    dpi = 96;
  };

  # Nvidia
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
  hardware.nvidia.prime = {
    sync.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  # hardware.nvidia.modesetting.enable = true;

  # Enable sound.
  sound.enable = true;
  sound.mediaKeys.enable = true;

  # Hardware
  hardware = {
    bluetooth.enable = true;
    pulseaudio = {
      enable = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cas1no = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "android-studio-stable"
    "discord"
    "nvidia-settings"
    "nvidia-x11"
    "skypeforlinux"
    "steam"
    "steam-original"
    "steam-runtime"
    "stm32cubemx"
    # "vscode-extension-ms-vscode-cpptools"
    "zerotierone"
    "unigine-valley"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    unigine-valley
    vscodium-fhs
    tdesktop
    zerotierone
    git
    neovim
    wget
    firefox
    chromium
    qbittorrent
    # redshift
    krita
    freerdp
    smplayer
    mpv
    # playerctl
    # android-studio
    pass
    socat
    openocd
    stm32cubemx
    gcc-arm-embedded
    jetbrains.pycharm-community
    gcc
    gnumake
    p7zip
    ripgrep
    # steam-run
    discord
    skype
  ];

  programs.steam.enable = true;

  fonts.fonts = with pkgs; [
    jetbrains-mono
  ];

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
    joinNetworks = [ "d3ecf5726d11fd54" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

