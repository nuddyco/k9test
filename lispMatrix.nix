# Test matrix: platform * lisp-impl * lisp-package
{
  nixpkgs
, systems ? [ "x86_64-linux" "aarch64-linux" ]
, lisps ? [ "sbcl" ]
}:

let basepkgs = import nixpkgs {};
    inherit (basepkgs.lib) recurseIntoAttrs listToAttrs;
in

recurseIntoAttrs (listToAttrs
  (map (system:
    { name = system;
      value = recurseIntoAttrs (listToAttrs
        (map (lisp:
          { name = lisp;
            value = (let pkgs = import nixpkgs { inherit system; };
                         api = pkgs.lispPackages_new;
                     in recurseIntoAttrs (api.lispPackagesFor (api.${lisp}))); })
          lisps));
    }) systems))
