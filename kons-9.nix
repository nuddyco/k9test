{ nixpkgs
, kons-9 }:

let pkgs = import nixpkgs {}; in

# Define a lisp distribution with all the libraries that we depend on
# (including their foreign dependencies e.g. OpenGL libraries.)
rec {
  # sbcl custom initialization
  sbcl-initrc = pkgs.writeText "sbcl-initrc.lisp"
  ''
    ;; CL-OpenGL default behaviour is to make prohibitively expensive
    ;; calls to mask floating point traps.
    ;; These are already set globally in kons-9 and redundant.
    ;; See: https://github.com/3b/cl-opengl#readme
    (pushnew :cl-opengl-no-masked-traps *features*)
  '';
  # sbcl customized startup script
  sbcl-script = "${pkgs.sbcl}/bin/sbcl --load ${sbcl-initrc} --script";
  # sbcl customized distribution with dependencies
  sbcl = pkgs.lispPackages_new.lispWithPackages sbcl-script (p:
    # List of packages to install. Update as needed.  Names are the
    # same as in Quicklisp (except leading _ if the first character is
    # numeric e.g. 1am => _1am.)
    with p; [ closer-mop
              trivial-main-thread
              trivial-backtrace
              cffi
              cl-opengl
              cl-glu
              cl-glfw3
              origin
              trivial-benchmark
            ]);
  # Define a development environment that auto-starts this Lisp.
  k9 = pkgs.mkShell {
    nativeBuildInputs =
      # Generate 'sbcl' script with all dependencies available and
      # kons-9.asd loaded.
      [ (pkgs.writeShellScriptBin "sbcl"
        ''
         exec ${sbcl}/bin/sbcl --load ${sbcl-initrc} \
                                   --eval "(require 'asdf)" \
                                                    --load ${kons-9}/kons-9.asd \
                               $@
       '')
      ];
  };
}
