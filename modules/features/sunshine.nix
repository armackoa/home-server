{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.sunshine = {
    config,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [moonlight-qt];

    #  UDP ports must be between 16384-32767
    services.sunshine = {
      enable = true;
      package = pkgs.sunshine.override {cudaSupport = true;};
      autoStart = false;
      capSysAdmin = true;
      openFirewall = false;

      applications = {
        env = {
          PATH = "$(PATH):${pkgs.util-linux}/bin";
        };
        apps = [
          {
            name = "Desktop";
            image-path = "desktop.png";
          }
          {
            name = "Steam Big Picture";
            detached = ["${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture"];
            image-path = "steam.png";
          }
        ];
      };

      settings = {
        port = 24700; # Web UI port

        encoder = "nvenc";

        hevc_mode = 2; # 0=off, 1=allow, 2=prefer, 3=force
        min_fps_factor = 1;
        audio_sink = "alsa_output.usb-Schiit_Audio_Schiit_Modi_-00.pro-output-0";
        virtual_sink = "sink-sunshine-stereo";
      };
    };
    systemd.user.services.sunshine = {
      serviceConfig = {
        PassEnvironment = [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "XAUTHORITY"
        ];
        Environment = [
          "LD_LIBRARY_PATH=${config.hardware.nvidia.package}/lib:/run/opengl-driver/lib"
          "PATH=${pkgs.cudaPackages.cudatoolkit}/bin:$PATH"
        ];
      };
      after = ["graphical-session.target"];
      wants = ["graphical-session.target"];
    };
    networking.firewall.allowedTCPPorts = [
      24695
      24700 # Base port
      24701 # Web UI
      24721
    ];

    networking.firewall.allowedUDPPorts = [
      24709
      24710
      24711
    ];

    networking.firewall.allowedUDPPortRanges = [
      {
        from = 24709;
        to = 24711;
      }
    ];
  };
}
