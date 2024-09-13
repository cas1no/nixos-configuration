# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cas1no = {
    isNormalUser = true;
    description = "cas1no";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  networking = {
    # Define your hostname.
    hostName = "nixos";

    # Enable networking
    networkmanager.enable = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  # List services that you want to enable:
  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # BluetoothManager
    blueman.enable = true;

    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Enable the LXQT Desktop Environment.
      desktopManager.lxqt.enable = true;
      displayManager.lightdm.enable = true;
      # Configure keymap in X11
      xkb = {
        layout = "us";
      };
      videoDrivers = [ "nvidia" ];
    };

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      mouse.accelProfile = "flat";
      touchpad = {
        accelProfile = "flat";
        accelSpeed = "1.0";
        naturalScrolling = true;
      };
    };

    # Enable sound with pipewire.
    pipewire = {
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

    redshift = {
      enable = true;
      temperature = {
        day = 3000;
        night = 3000;
      };
    };
  };

  # Needed to make redshift work.
  location.latitude = 0.0;
  location.longitude = 0.0;

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  security.rtkit.enable = true;

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
      enable = false;
      package = pkgs.pulseaudioFull;
    };
  };

  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts-cjk
    google-fonts
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
    "nvidia-settings"
    "nvidia-x11"
    "steam"
    "steam-run"
    "steam-original"
    "steam-runtime"
    "calibre"
    "unrar"
    "chromium"
    "chromium-unwrapped"
    "widevine-cdm"
  ];

  nixpkgs.config.nvidia.acceptLicense = true;

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
      (chromium.override {
        enableWideVine = true;
      })
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
      (calibre.override {
        unrarSupport = true;
      })
      valgrind
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    # Enable network manager applet
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
  system.stateVersion = "23.05"; # Did you read the comment?
}
