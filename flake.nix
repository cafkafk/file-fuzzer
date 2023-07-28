{
  description = "A file fuzzer with fortune";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-23.05";

  outputs = { self, nixpkgs }:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {
      # A Nixpkgs overlay.
      overlay = final: prev: {
        # Our simple file clone
        sfile = with final; stdenv.mkDerivation rec {
          pname = "sfile";
          inherit version;

          src = ./.;

          nativeBuildInputs = [ autoreconfHook ];
        };

        # Our file fuzzer, dependent on the simple file clone
        file-fuzzer = with final; stdenv.mkDerivation rec {
          pname = "file-fuzzer";
          inherit version;

          src = ./.;

          phases = "installPhase";

          buildInputs = [ sfile lolcat ];

          nativeBuildInputs = [ makeWrapper ];

          installPhase = ''
            mkdir -p $out/bin
            cp $src/file-fuzzer $out/bin/file-fuzzer
            wrapProgram $out/bin/file-fuzzer \
              --prefix PATH : ${lib.makeBinPath [ sfile lolcat ]}
          '';
        };
      };



      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) sfile file-fuzzer;
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.file-fuzzer);

      # Tests run by 'nix flake check' and by Hydra.
      checks = forAllSystems
        (system:
          with nixpkgsFor.${system};

          {
            inherit (self.packages.${system}) sfile;

            # Additional tests, if applicable.
            test = stdenv.mkDerivation {
              pname = "sfile-test";
              inherit version;

              buildInputs = [ sfile ];

              dontUnpack = true;

              buildPhase = ''
                echo 'running some integration tests' | tee test-file.txt
                [[ $(sfile test-file.txt) = 'test-file.txt: ASCII text' ]]
              '';

              installPhase = "mkdir -p $out";
            };
          }
        );
    };
}
