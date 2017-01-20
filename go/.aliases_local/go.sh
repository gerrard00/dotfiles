
#setup gocd to go home
function gocd() {
  cd $GOPATH/$1
}

function gosrccd() {
  cd $GOPATH/src/github.com/gerrard00/$1
}

# set gopath here, so it's only set
# on machine where I use go
export GOPATH=~/go
export PATH=$PATH:$GOPATH/bin

