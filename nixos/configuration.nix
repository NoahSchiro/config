{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Define your hostname.
  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS        = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT    = "en_US.UTF-8";
      LC_MONETARY       = "en_US.UTF-8";
      LC_NAME           = "en_US.UTF-8";
      LC_NUMERIC        = "en_US.UTF-8";
      LC_PAPER          = "en_US.UTF-8";
      LC_TELEPHONE      = "en_US.UTF-8";
      LC_TIME           = "en_US.UTF-8";
    };

    # Mandarin input
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
	fcitx5-gtk
      ];
    };
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

    # Make dark theme
    GTK_THEME = "Adwaita:dark";

    # Mandarin support
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
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

  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Packages
  environment.systemPackages = with pkgs; [

    # GUI programs
    firefox
    bitwarden-desktop
    anki

    # Terminal programs
    ffmpeg_7
    neofetch
    alacritty
    vim
    neovim
    wget
    btop
    git
    tree
    file
    yt-dlp

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

  # Python needs to be able to link to various things
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    portaudio
    openblas
    cudaPackages_12.cudatoolkit
    cudaPackages_12.libcublas
    cudaPackages_12.cudnn
    linuxPackages.nvidia_x11
  ];

  # Do not edit this line ever
  system.stateVersion = "25.11"; # Did you read the comment?
  # Nah for real, did you read the comment?
}
