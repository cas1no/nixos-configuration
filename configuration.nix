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
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cas1no = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  networking = {
    # Define your hostname.
    hostName = "nixos";

    # NetworkManager
    networkmanager.enable = true;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces = {
      enp14s0.useDHCP = true;
      wlp13s0.useDHCP = true;
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # List services that you want to enable:
  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # BluetoothManager
    blueman.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      desktopManager.lxqt.enable = true;
      displayManager.defaultSession = "lxqt";
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
    };
  };

  # Hardware
  hardware = {
    # Nvidia
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
      modesetting.enable = true;
      prime = {
        offload.enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };

    bluetooth.enable = true;

    pulseaudio = {
      enable = true;
      # extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
    };
  };

  # Enable sound.
  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  fonts.fonts = with pkgs; [
    jetbrains-mono
    noto-fonts-cjk
    google-fonts
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
    "nvidia-settings"
    "nvidia-x11"
    "steam"
    "steam-original"
    "steam-runtime"
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
      tdesktop
      git
      wget
      firefox
      chromium
      qbittorrent
      krita
      smplayer
      mpv
      pass
      gcc
      gnumake
      p7zip
      ripgrep
      discord
      xclip
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    nm-applet.enable = true;

    steam.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    neovim = let unstable = import <nixos-unstable> {};
      in {
        enable = true;
        defaultEditor = true;
        package = unstable.neovim-unwrapped;
      };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

