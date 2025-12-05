# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ 
      <nixos-hardware/framework/13-inch/12th-gen-intel>
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-27.3.11"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  networking.hostName = "frame"; # Define your hostname.

  # Frakework stuff
  services.fwupd.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

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


  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver = {
    enable = true;

    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.displayManager = {
    sddm.enable = true;
    autoLogin.enable = true;
    autoLogin.user = "nullreff";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      Experimental = true;
      Enable = "Source,Sink,Media,Socket";
    };
  };
  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [ "network.target" "sound.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  virtualisation.docker.enable = true;

  programs.noisetorch.enable = true;
  programs.kdeconnect.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nullreff = {
    isNormalUser = true;
    description = "nullreff";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      # CLI stuff
      fish
      bitwarden-cli
      yubikey-manager
      rsync
      rclone
      yt-dlp
      drill
      silver-searcher
      git-lfs
      git-filter-repo
      whois
      neofetch
      ffmpeg
      nmap
      gnumake

      # Wine
      vulkan-tools
      (pkgs.lutris.override {
        extraPkgs = pkgs: [
          pkgs.wineWowPackages.stagingFull
          pkgs.winetricks
        ];
      })

      # Desktop
      firefox
      bitwarden-desktop
      steam
      steam-run-free
      syncthing
      #cheese

      # Productivity
      logseq
      vscode
      libreoffice
      gimp
      krita
      #darktable
      blender
      bitwig-studio
      davinci-resolve
      obs-studio
      #unityhub
      qlcplus

      # Social
      telegram-desktop
      discord
      slack
      gajim
      vrcx

      # Media
      vlc
      mpv
      tidal-hifi
      mopidy
      mopidy-iris
      mopidy-tidal
      yabridge
      reaper
      mixxx
      
      # Remote Access
      parsec-bin
      tailscale
      protonvpn-gui
      
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "nullreff" ];
      commands = [
        {
          command = "ALL" ;
          options= [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List packages installed in system profile. To search, run
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    htop
    tree
    parted
    gparted
    cups
    ntfs3g
    exfat
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.syncthing.enable = true;

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
  system.stateVersion = "23.11"; # Did you read the comment?

}
