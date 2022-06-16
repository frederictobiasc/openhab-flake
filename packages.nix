{ stdenv
, lib
, fetchurl
}:

let
  urls = { pname, version, ext }:
    let
      path = "org/openhab/distro/${pname}/${version}/${pname}-${version}.${ext}";
    in
    [
      "https://openhab.jfrog.io/artifactory/libs-release-local/${path}"
      "https://openhab.jfrog.io/artifactory/libs-milestone-local/${path}"
      "https://bintray.com/openhab/mvn/download_file?file_path=${path}"
    ];

  addon = { pname, version, hash }:
    stdenv.mkDerivation rec {
      inherit pname version;

      src = fetchurl {
        urls = urls { inherit pname version; ext = "kar"; };
        inherit hash;
      };

      buildCommand = ''
        install -Dm444 $src $out/share/openhab/addons/${src.name}
      '';
    };

  generic = { version, hash }:
    stdenv.mkDerivation rec {
      pname = "openhab";
      inherit version;

      src = fetchurl {
        urls = urls { inherit pname version; ext = "tar.gz"; };
        inherit hash;
      };

      sourceRoot = ".";

      dontConfigure = true;

      dontBuild = true;

      postPatch = ''
        dir=runtime/bin

        rm $dir/*.{bat,lst,ps1,psm1}

        for file in oh2_dir_layout oh_dir_layout; do
          if [ -e  $dir/$file ]; then
            sed -i $dir/$file \
              -e '/export OPENHAB_HOME/d'
          fi
        done
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/openhab
        cp -r * $out/share/openhab/

        runHook postInstall
      '';

      meta = with lib; {
        description = "OpenHAB - vendor and technology agnostic open source home automation software";
        homepage = "https://www.openhab.org";
        license = licenses.epl10;
        maintainers = with maintainers; [ peterhoeg ];
      };
    };

in
rec {
  openhab2 = generic {
    version = "2.5.12";
    hash = "sha256-JOinHmvCIwOAAWOHHRwFVIQ/oZ6c1zbmvnIaoHmLvjo=";
  };

  openhab2-v1-addons = addon {
    pname = "openhab-addons-legacy";
    hash = "sha256-5yDC6L+azep6UOa9FOM8trSxffsAVqdusVQRGF74X3w=";
    inherit (openhab2) version;
  };

  openhab2-v2-addons = addon {
    pname = "openhab-addons";
    hash = "sha256-ZUSjI68R9Xfd5zb2lCxYM4edC0F3BwD8xmehiHVcbM4=";
    inherit (openhab2) version;
  };

  # V3+ has no legacy addons

  openhab31 = generic {
    version = "3.1.1";
    hash = "sha256-nPv3mtciDQVT/BWvIiX8JZfxlVJDX/QbIXLDsUv8RDA=";
  };

  openhab31-addons = addon {
    pname = "openhab-addons";
    hash = "sha256-5c9a3MnHJBnTY69Rpkg+TvpxHgwHGmoOz/UoV7/pqPo=";
    inherit (openhab31) version;
  };

  openhab32 = generic {
    version = "3.2.0";
    hash = "sha256-6Bha3Kq97EuGDCLshU832wqkkNR+P4ZUzvDx3XNG1HY=";
  };

  openhab32-addons = addon {
    pname = "openhab-addons";
    hash = "sha256-VD07+m3Okh+5/PuXEFhG2kqi1crNrWvpEKNAxcMAB6w=";
    inherit (openhab32) version;
  };

  openhab33 = generic {
    version = "3.3.0.M5";
    hash = "sha256-Z5ePvimj2kVWIs7TDLSoQzpscu3mDyWbRwKdKAT1IbI=";
  };

  openhab33-addons = addon {
    pname = "openhab-addons";
    hash = "sha256-k0vbyyVbyJe/hM4tcl6lazc5cl509kS0YwT0CXLkrLU=";
    inherit (openhab33) version;
  };

  openhab-stable = openhab32;
  openhab-stable-addons = openhab32-addons;
}