#!/bin/bash

script_directory="$(cd -- "$(dirname -- "$0")" && pwd)"
exec "$script_directory/install-work.command" execute
