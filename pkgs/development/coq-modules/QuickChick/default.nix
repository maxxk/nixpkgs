{stdenv, fetchgit, coq, coqPackages}:

let revision = "b73a594af5460567dc233b2f2e7b0f781ae0490d"; in

stdenv.mkDerivation rec {

  name = "coq-QuickChick-${coq.coq-version}-${version}";
  version = "20150605-${builtins.substring 0 7 revision}";

  src = fetchgit {
    url = git://github.com/QuickChick/QuickChick.git;
    rev = revision;
    sha256 = "1yql40x1zbrc6wzfafvfaxzhw57v1n468lxdv1rvsjd7gyyf74y7";
  };

  buildInputs = [ coq.ocaml coq.camlp5 ];
  propagatedBuildInputs = [ coq coqPackages.ssreflect ];

  enableParallelBuilding = true;

  installFlags = "COQLIB=$(out)/lib/coq/${coq.coq-version}/";

  meta = with stdenv.lib; {
    homepage = git://github.com/QuickChick/QuickChick.git;
    description = "Randomized property-based testing plugin for Coq; a clone of Haskell QuickCheck";
    maintainers = with maintainers; [ jwiegley ];
    platforms = coq.meta.platforms;
  };

}
