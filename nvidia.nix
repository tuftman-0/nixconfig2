{ config, lib, pkgs, ... }:
{

  # Enable OpenGL?
  hardware.graphics = {
    enable = true;
  };

  #   driSupport = true;
  #   driSupport32Bit = true;
  #   extraPackages = with pkgs; [
  #     # trying to fix `WLR_RENDERER=vulkan sway`
  #     vulkan-validation-layers
  #   ];
  nixpkgs.config.cudaSupport = true;
  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
    # displayManager.gdm = {
    #   enable = true;
    #   wayland = true;
    # };
  };

  # ollama
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };

  # Load nvidia driver for Xorg and Wayland
  nixpkgs.config.nvidia.acceptLicense = true;
  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  # hardware.opengl = {
  #   nvidia-vaapi-driver
  # };
}
