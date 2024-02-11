{ config, lib, pkgs, modulesPath, ... }:

# Copy jar file cli-maas-2.4.0 to store in order to be run with a wrapper
# script.
let
  cliWrapper = pkgs.writeShellScriptBin "cli-maas" ''
    export MAAS_LEVEL=trace

    # There should be all those values set :
    # - <commit-sha>
    # - <student-path>

    if [ "$#" -ne 2 ]; then
      echo "Usage: $0 <commit-sha> <student-path>"
      exit 1
    fi

    commit_sha=$1
    student_path=$2

    # Check that maasWorkflow.yml exists in current directory
    if [ ! -f maasWorkflow.yml ]; then
      echo "maasWorkflow.yml not found in current directory"
      exit 1
    fi

    # Check taht testsuite folder exists in current directory
    if [ ! -d testsuite ]; then
      echo "testsuite folder not found in current directory"
      exit 1
    fi

    cp maasWorkflow.yml /tmp/maasWorkflow.yml
    # Replace %%COMMIT_SHA%% by commit_sha
    sed -i "s/%%COMMIT_SHA%%/$commit_sha/g" /tmp/maasWorkflow.yml

    TMP_FOLDER=/tmp/maas
    if [ -d "$TMP_FOLDER" ]; then
      rm -rf "$TMP_FOLDER"
    fi

    # Package student path with local testsuite folder
    # The student path folder should be renamed student
    # In order to rename correctly, we need to remove the the leading slash
    # and the trailing slash if those exist
    sed_student_path=$(echo "$student_path" | sed 's,^/,,g' | sed 's,/$,,g')
    tar cvf /tmp/student.tar "$student_path/" "testsuite/" --transform "s,^$sed_student_path,student,"

    # Run maas
    ${pkgs.openjdk17}/bin/java -jar ${cliMaas}/bin/cli-maas run --delete-mounts -w "$TMP_FOLDER" /tmp/maasWorkflow.yml /tmp/student.tar trace.xml
  '';
  cliMaas = pkgs.stdenv.mkDerivation {
    name = "cli-maas-1.4.0";
    src = ./cli-maas-1.4.0.jar;
    phases = [ "installPhase" ];
    buildInputs = [ pkgs.openjdk17 ];

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/cli-maas
      chmod +x $out/bin/cli-maas
    '';

    meta = with lib; {
      description = "CLI for MAAS";
      homepage = "";
      license = licenses.gpl3;
      platforms = platforms.all;
    };
  };
in {
  environment.systemPackages = with pkgs; [
    cliWrapper
    cliMaas
  ];
}

