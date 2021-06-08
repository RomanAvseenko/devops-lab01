#!/bin/bash

NAME_VM1="vm-01"
NAME_VM2="vm-02"

function testinfra_setup {
 
  if ! brew ls --formulae | grep -q "python@3.*"; then
    echo "Python3 is not installed!"
    exit 1
  elif ! python3 -m pip --version > /dev/null; then
    echo "PIP is not installed!"
    exit 1
  else	
    pip install pytest-testinfra
    pip install paramiko
  fi

}

function vm_test {
  echo "Testing ${1}"

  vagrant ssh-config "$1" > ".vagrant/ssh-config-${1}"
  py.test -v --hosts="${1}" --ssh-config=".vagrant/ssh-config-${1}" "test-${1}.py"
}

testinfra_setup
vm_test $NAME_VM1
vm_test $NAME_VM2
