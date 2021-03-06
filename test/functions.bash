info() {
  echo
  echo "[INFO] $@"
}

smitty() {
  echo
  echo "[RUN] $@"
  "$@"
}

err() {
  echo "[ERROR] $@" >&2
  exit 1
}

# On CoreOS, /var/run is a symlink to /run:
#
# core@ip-192-168-254-162 ~ $ ls -ld /run
# drwxr-xr-x 17 root root 420 Jan 31 20:49 /run
#
# core@ip-192-168-254-162 ~ $ ls -ld /var/run
# lrwxrwxrwx 1 root root 4 Jul 12  2014 /var/run -> /run
volumes="
  -v /etc/bar:/etc/bar
  -v /var/lib/puppet:/var/lib/puppet
  -v /etc/os-release:/etc/os-release:ro
  -v /usr/bin/systemctl:/usr/bin/systemctl:ro
  -v /lib64:/lib64:ro
"
if ! [ ${CIRCLECI} ]; then
  volumes="
    ${volumes}
    -v /run:/run:ro
    -v /sys/fs/cgroup:/sys/fs/cgroup:ro
  "
fi

docker_run() {
  image=$1; shift
  entrypoint=$1; shift
  command=$@

  [ -n "$entrypoint" ] && entrypoint="--entrypoint $entrypoint"

  smitty docker run -t $volumes $entrypoint $image $command
}
