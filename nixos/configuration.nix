# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

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

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Required for Wayland
    modesetting.enable = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Use the open source kernel module (only for Turing/Ampere+ i.e. RTX 20xx+)
    # Set to false if you have an older card
    open = false;

    # Enable the nvidia-settings utility
    nvidiaSettings = true;
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For 32 bit apps (steam)
  };

  # Required environment variables for Wayland + NVIDIA
  environment.sessionVariables = {
    # For Electron apps and others to use Wayland
    NIXOS_OZONE_WL = "1";
    
    # Tell apps to use the NVIDIA card
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    
    # Sometimes needed for cursor rendering
    WLR_NO_HARDWARE_CURSORS = "1";

    # If using a compositor like Hyprland or sway that uses wlroots:
    WLR_RENDERER = "vulkan"; # optional
  };


  programs.sway = {
    enable = false;
    #wrapperFeatures.gtk = true;
  };
  
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd 'dbus-run-session sway'";
	user = "greeter";
      };
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.noah = {
    isNormalUser = true;
    description = "Noah Schiro";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Make dark theme
  environment.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
  };

  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    firefox
    bitwarden-desktop
    neofetch
    alacritty
    vim
    neovim
    wget
    btop
    git
    tree

    # Programming languages
    nodejs_24
    rustup
    python3
    uv
    go
    typst

    # Themes
    gnome-themes-extra
    gtk-engine-murrine
     
    # Desktop management stuff
    swayfx        # Tiling window manager
    swaylock      # Lock screen
    swayidle      # Idle time out
    swaybg        # Set background images
    waybar        # Status bar
    wofi          # Program launcher
    nemo          # Package manager
    pavucontrol   # Sound
    brightnessctl # Brightness
    grim          # Screenshots
    slurp         # Screenshots
    imv           # View images
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
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
