self@{ config, pkgs, boot, nix-alien, ... }:
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
    mesa-demos
    nvidia-offload
    vulkan-loader
  ];


  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  # hardware.graphics.extraPackages32 = with pkgs;[
  #   rocm-opencl-icd
  #   rocm-opencl-runtime
  #   mesa
  # ];
  hardware.graphics.extraPackages = with pkgs;[
    # rocm-opencl-icd
    # rocm-opencl-runtime
    mesa
  ];

  # hardware.opengl.driSupport = true; # No longer needed
  # hardware.opengl.driSupport32Bit = true;

  hardware.nvidia = {
    open = true;
    # package = config.boot.kernelPackages.nvidiaPackages.stable; # stable
    # package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta; # stable
    forceFullCompositionPipeline = false;
    package = config.boot.kernelPackages.nvidiaPackages#.beta; # beta
    # # for using specific driver version:
    .beta
    ;
    # .overrideAttrs {
    #   version = "575.64.05";
    #   # the new driver
    #   src = pkgs.fetchurl
    #     {
    #       url = "https://us.download.nvidia.com/XFree86/Linux-x86_64/575.64.05/NVIDIA-Linux-x86_64-575.64.05.run";
    #       sha256 = "sha256-hfK1D5EiYcGRegss9+H5dDr/0Aj9wPIJ9NVWP3dNUC0=";
    #     };
    # };
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    # nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  # hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.prime.allowExternalGpu = true;
}
