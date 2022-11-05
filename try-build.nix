{
  nixpkgs ? <nixpkgs>
}:
with import nixpkgs {};

let
  expr = pkg: writeText "${pkg}.nix" ''
    with import <nixpkgs> {};
    lispPackages_new.sbclPackages.${pkg}
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
        nix --max-build-log-size 10000 --log-lines 10000 \
            --experimental-features "nix-command recursive-nix" \
            build -v -L -f ${expr pkg} \
              2>&1 | tee $out/output.log
        set -e
    '';
all = builtins.mapAttrs (name: value: try name) lispPackages_new.sbclPackages;
in
runCommand "test" all
  ''
    export > $out
  ''
#  try package
#      nix --experimental-features "nix-command recursive-nix" log -f ${expr} &> $out/error.log
