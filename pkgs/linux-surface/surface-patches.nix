{ fetchFromGitHub, ... }:
let
  linuxSurface = fetchFromGitHub {
    owner = "linux-surface";
    repo = "linux-surface";
    rev = "daac927ae7cb7b87c81b22bb32789e1065e118e3";
    hash = "sha256-IuQ34p/6cn25DU1sDpJAIwKu5avuFOStnzqZeMlx+Yo=";
  };
in map (pname: {
  name = "linux-surface-${pname}";
  patch = (linuxSurface + "/patches/6.8/${pname}.patch");
}) [
  "0004-ipts"
  "0005-ithc"
  "0006-surface-sam"
  "0009-surface-typecover"
  "0010-surface-shutdown"
  "0011-surface-gpe"
  "0014-rtc"
]