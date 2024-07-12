{ pkgs, ... }:
{
  home.packages = with pkgs; [ dotnet-sdk_8 ];

  # Opt out of telemetry
  # Thanks Microsoft :/
  home.sessionVariables.DOTNET_CLI_TELEMETRY_OPTOUT = 1;

  programs.helix = {
    extraPackages = with pkgs; [
      omnisharp-roslyn # C# language server
      fsautocomplete # F# language server
      fantomas # F# code formatter
      netcoredbg # debugger
    ];
    languages.language = [
      {
        name = "c-sharp";
        auto-format = true;
      }
    ];
  };
}
