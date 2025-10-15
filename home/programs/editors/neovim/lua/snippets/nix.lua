local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local nix_snippets = {
      -- Basic flake
      s(
        "nixflake",
        fmt(
          [[
{{
  description = "{}";

  inputs = {{
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    {}
  }};

  outputs = {{ self, nixpkgs, ... }}@inputs: {{
    {}
  }};
}}]],
          {
            i(1, "A very basic flake"),
            i(2, "# Additional inputs"),
            i(3, "# Outputs"),
          }
        )
      ),

      -- Home Manager module
      s(
        "nixhm",
        fmt(
          [[
{{ config, lib, pkgs, ... }}:

{{
  home.packages = with pkgs; [
    {}
  ];

  programs.{} = {{
    enable = true;
    {}
  }};
}}]],
          {
            i(1, "# packages"),
            i(2, "program"),
            i(3, "# configuration"),
          }
        )
      ),

      -- NixOS module
      s(
        "nixmodule",
        fmt(
          [[
{{ config, lib, pkgs, ... }}:

with lib;

let
  cfg = config.{};
in {{
  options.{} = {{
    enable = mkEnableOption "{}";

    {} = mkOption {{
      type = types.{};
      default = {};
      description = "{}";
    }};
  }};

  config = mkIf cfg.enable {{
    {}
  }};
}}]],
          {
            i(1, "services.myservice"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(2, "my service"),
            i(3, "package"),
            i(4, "package"),
            i(5, "pkgs.hello"),
            i(6, "Package to use"),
            i(7, "# Module configuration"),
          }
        )
      ),

      -- Shell script with Nix
      s(
        "nixscript",
        fmt(
          [[
{{ pkgs ? import <nixpkgs> {{}} }}:

pkgs.writeScriptBin "{}" ''
  #!${{pkgs.bash}}/bin/bash
  set -euo pipefail

  {}
'']],
          {
            i(1, "script-name"),
            i(2, "# Script content"),
          }
        )
      ),

      -- Package derivation
      s(
        "nixpkg",
        fmt(
          [[
{{ lib
, stdenv
, fetchFromGitHub
, {}
}}:

stdenv.mkDerivation rec {{
  pname = "{}";
  version = "{}";

  src = fetchFromGitHub {{
    owner = "{}";
    repo = "{}";
    rev = "v${{version}}";
    sha256 = "{}";
  }};

  buildInputs = [ {} ];

  installPhase = ''
    {}
  '';

  meta = with lib; {{
    description = "{}";
    homepage = "https://github.com/{}/{}";
    license = licenses.{};
    maintainers = with maintainers; [ {} ];
  }};
}}]],
          {
            i(1, "dependencies"),
            i(2, "package-name"),
            i(3, "0.1.0"),
            i(4, "owner"),
            i(5, "repo"),
            i(6, "sha256-AAAA..."),
            i(7, "dependencies"),
            i(8, "# Install commands"),
            i(9, "Package description"),
            f(function(args)
              return args[1][1]
            end, { 4 }),
            f(function(args)
              return args[1][1]
            end, { 5 }),
            i(10, "mit"),
            i(11, "yourname"),
          }
        )
      ),

      -- Overlay
      s(
        "nixoverlay",
        fmt(
          [[
final: prev: {{
  {} = prev.{}.overrideAttrs (oldAttrs: {{
    {}
  }});
}}]],
          {
            i(1, "package-name"),
            f(function(args)
              return args[1][1]
            end, { 1 }),
            i(2, "# Attribute overrides"),
          }
        )
      ),

      -- Let binding
      s("nixlet", fmt("let\n  {} = {};\nin {}", { i(1, "name"), i(2, "value"), i(3, "expression") })),

      -- mkIf
      s("nixif", fmt("mkIf {} {{\n  {}\n}}", { i(1, "condition"), i(2, "# config") })),

      -- mkOption
      s(
        "nixopt",
        fmt(
          [[
{} = mkOption {{
  type = types.{};
  default = {};
  description = "{}";
}};]],
          {
            i(1, "optionName"),
            i(2, "str"),
            i(3, '""'),
            i(4, "Option description"),
          }
        )
      ),
    }

return nix_snippets
