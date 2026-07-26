{ pkgs, ... }: {
  programs.vscode = {
    enable = true;

    profiles.default = {
      enableUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        biomejs.biome
        bradlc.vscode-tailwindcss
        charliermarsh.ruff
        github.copilot
        github.copilot-chat
        hediet.vscode-drawio
        humao.rest-client
        ms-python.debugpy
        ms-python.python
        ms-python.vscode-pylance
      ];

      userSettings = {
        "files.autoSave" = "onFocusChange";
        "editor.formatOnSave" = true;
        "prettier.enabled" = false;

        "chat.agent.enabled" = true;
        "telemetry.telemetryLevel" = "off";
        "github.copilot.nextEditSuggestions.enabled" = true;
        "github.copilot.chat.agent.thinkingTool" = true;
        "github.copilot.chat.editor.temporalContext.enabled" = true;

        "[javascript]"."editor.defaultFormatter" = "biomejs.biome";
        "[json]"."editor.defaultFormatter" = "biomejs.biome";
        "[jsonc]"."editor.defaultFormatter" = "biomejs.biome";
        "[typescript]"."editor.defaultFormatter" = "biomejs.biome";
        "[typescriptreact]"."editor.defaultFormatter" = "biomejs.biome";

        "[python]"."editor.defaultFormatter" = "charliermarsh.ruff";

        "editor.codeActionsOnSave" = {
          "quickfix.biome" = "explicit";
          "source.fixAll.biome" = "explicit";
          "source.organizeImports.biome" = "explicit";
        };

        "editor.quickSuggestions" = {
          "strings" = "on";
        };
      };
    };
  };
}
