# taken from https://github.com/0x006E/dotfiles/blob/f276efce15e46316574780ea5cfca25ac19ac14d/acer-wmi-battery.nix
{ pkgs, config, ... }:
let
  kernel-module-builder =
    { stdenv, lib, fetchFromGitHub, kernel, kmod }:
    stdenv.mkDerivation rec {
      name = "acer-wmi-battery-${version}-${kernel.modDirVersion}";
      version = "unstable-2023-06-12";

      src = fetchFromGitHub {
        owner = "frederik-h";
        repo = "acer-wmi-battery";
        rev = "4e605fb2c78412e0c431a06e9f8ee17c9e0e0095";
        sha256 = "0b8h4qgqdgmzmzb2hvsh4psn3d432klxdfkjsarpa89iylr4irfs";
      };

      hardeningDisable = [
        "pic"
        "format"
      ]; # 1

      nativeBuildInputs = kernel.moduleBuildDependencies; # 2
      patches = [ ./acer-patch.patch ];

      makeFlags = [
        "KERNELRELEASE=${kernel.modDirVersion}" # 3
        "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" # 4
        "INSTALL_MOD_PATH=$(out)" # 5
      ];

      meta = with lib; {
        description = "A linux kernel driver for the Acer WMI battery health control interface";
        homepage = "https://github.com/frederik-h/acer-wmi-battery";
        license = licenses.gpl2;
        maintainers = [ ];
        platforms = platforms.linux;
      };
    };
in
{
  boot = {
    extraModulePackages = [ (config.boot.kernelPackages.callPackage kernel-module-builder { }) ];
    kernelModules = [
      "acer-wmi-battery"
    ];
    extraModprobeConfig = ''
      options acer_wmi_battery enable_health_mode=1
    '';
  };
}
