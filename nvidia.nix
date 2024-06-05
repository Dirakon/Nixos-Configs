self@{ config, pkgs, boot, unstable, nix-alien, nix-gl, agenix, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    glxinfo
    nvidia-offload
    vulkan-loader
  ];

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs;[
    rocm-opencl-icd
    rocm-opencl-runtime
    mesa.drivers
  ];

  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.nvidia = {
    # package = config.boot.kernelPackages.nvidiaPackages.stable; # stable
    package = config.boot.kernelPackages.nvidiaPackages.beta; # beta
    # for using specific driver version:
    # .beta.overrideAttrs {
    #   version = "550.40.07";
    # t#he new driver
    #   src = pkgs.fetchurl
    #   {
    #     url = "https://download.nvidia.com/XFree86/Linux-x86_64/550.40.07/NVIDIA-Linux-x86_64-550.40.07.run";
    #     sha256 = "sha256-KYk2xye37v7ZW7h+uNJM/u8fNf7KyGTZjiaU03dJpK0=";
    #   };
    # };    
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.prime.allowExternalGpu = true;
}
