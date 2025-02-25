#!/usr/bin/env bash
# set -x

split_arg() {
    split=(${1//|/ })
    yml="${split[0]}"
    sleep_duration="${split[1]}"
}

service_start() {
    split_arg $1

    echo
    echo "Starting: $yml"

    if [[ -n "$sleep_duration" ]]; then
        echo "Sleeping for $sleep_duration"
        sleep "$sleep_duration"
    fi

    docker compose -f "$yml" up -d
}

service_update() {
    split_arg $1

    echo
    echo "Updating & Starting: $yml"

    if [[ -n "$sleep_duration" ]]; then
        echo "Sleeping for $sleep_duration"
        sleep "$sleep_duration"
    fi

    # Sometimes pull can fail. If it does, we still want to continue
    docker compose -f "$yml" pull || true
    docker compose -f "$yml" up -d
}

service_stop() {
    split_arg $1

    echo
    echo "Stopping: $yml"

    # If the down command fails, ignore it by piping to `true`
    docker compose -f "$yml" stop || true
}

service_down() {
    split_arg $1

    echo
    echo "Tearing Down: $yml"

    # If the down command fails, ignore it by piping to `true`
    docker compose -f "$yml" down || true
}

trap 'echo "Exiting...";  exit;' SIGINT SIGTERM

# Grab the first argument, which should be 'start' or 'stop'
# The 2nd and onward args are services (stacks) to exclude
operation_name="$1"
shift

case "$operation_name" in
    start) operation=service_start ;;
    stop) operation=service_stop ;;
    down) operation=service_down ;;
    update) operation=service_update ;;
    *) echo "Unknown operation: $1"; exit 1 ;;
esac

docker_path=/mnt/fast/docker

# Service dirs starting with an underscore are considered "manual"
exclude_dirs=( "uptime_kuma" "_*" "$@" )
for i in "${exclude_dirs[@]}"; do
    findargs+=('!' '-path' "$docker_path/$i/*")
done
yml_files="$(find "$docker_path" -maxdepth 2 -type f -name docker-compose.yml "${findargs[@]}")"

# When stopping, put uptime kuma first since it's responsible for status checks and we do not want
# it reporting on containers we take down for backup. When starting, put it last for the same
# reason.
uptime_kuma="$docker_path/uptime_kuma/docker-compose.yml|10s"
case "$operation_name" in
    start) yml_files="$(printf "$yml_files\n$uptime_kuma")" ;;
    stop) yml_files="$(printf "$uptime_kuma\n$yml_files")" ;;
    down) yml_files="$(printf "$uptime_kuma\n$yml_files")" ;;
esac

for yml in $yml_files; do
    $operation "$yml"
done

if [[ "$operation_name" == "start" ]]; then
    echo
    echo "Performing system prune..."
    docker system prune -af
    echo "Done"
fi
