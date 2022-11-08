{
  nixpkgs ? <nixpkgs>
}:
with import nixpkgs {};

let
  expr = pkg: writeText "${pkg}.nix" ''
    with import <nixpkgs> {};
    lispPackages_new.sbclPackages.${pkg} // { build_for_test = "a"; }
  '';
  try = pkg:
    runCommand "try-${pkg}"
      {
        inherit nixpkgs;
        nativeBuildInputs = [ nixUnstable ];
        requiredSystemFeatures = [ "recursive-nix" ];
      #  succeedOnFailure = true;
      }
      ''
        set +o pipefail
        set +e
        failureHook="echo FAILURE FAILURE FAILURE; exit 0"
        mkdir $out
        export NIX_PATH=nixpkgs=$nixpkgs
        nix  \
            --experimental-features "nix-command recursive-nix" \
            build --no-sandbox --impure --log-lines 30 -v -L -f ${expr pkg} \
              2>&1 | tee $out/output.log
        echo "Build completed with status: $?"

        # Make build artifacts available via Hydra UI
        mkdir -p $out/nix-support
        for f in $(ls $out/* | sort); do
          if [ -f $f  ]; then
            echo "file log $f" >> $out/nix-support/hydra-build-products
          fi
        done
        set -e
    '';
all = builtins.mapAttrs (name: value: try name)
  (lib.filterAttrs (name: value: name == "bmas") lispPackages_new.sbclPackages);
#   lispPackages_new.sbclPackages;
in
all
#  try package
#      nix --experimental-features "nix-command recursive-nix" log -f ${expr} &> $out/error.log
