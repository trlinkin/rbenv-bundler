# Copyright 2012 Roy Liu
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# Contains includes common to rbenv-bundler plugin scripts.

# Inspects the gemspec manifests generated by the rehash.rb script to see if there's a suitable gem executable for the
# given rbenv command.
function find_bundled_executable {

    local -- manifest_dir="${plugin_root_dir}/share/rbenv/bundler"
    local -- manifest_entries

    if [[ -f "${manifest_dir}/manifest.txt" ]]; then
        manifest_entries=$(cat -- "${manifest_dir}/manifest.txt")
    else
        manifest_entries=()
    fi

    ifs_save=$IFS

    IFS=$'\n'
    manifest_entries=($manifest_entries)
    IFS=$ifs_save

    local -- project_dir
    local -- gemspec_entries

    for (( i = 0; i < ${#manifest_entries[@]}; i += 2 )); do

        project_dir=$(dirname -- "${manifest_entries[$i]}")

        # Check if the manifest directory is a prefix of the current directory.
        if [[ "$project_dir" != "${PWD:0:${#project_dir}}" ]]; then
            continue
        fi

        gemspec_entries=$(cat -- "${manifest_dir}/${manifest_entries[$(($i + 1))]}")

        ifs_save=$IFS

        IFS=$'\n'
        gemspec_entries=($gemspec_entries)
        IFS=$ifs_save

        for (( j = 0; j < ${#gemspec_entries[@]}; j += 2 )); do

            if [[ "${gemspec_entries[$j]}" != "$RBENV_COMMAND" ]]; then
                continue
            fi

            echo "${gemspec_entries[$(($j + 1))]}/${gemspec_entries[$j]}"

            return -- 0
        done
    done

    return -- 1
}

# The plugins root directory.
plugin_root_dir=$(dirname -- "$(dirname -- "$(dirname -- "$(dirname -- "${BASH_SOURCE[0]}")")")")

# Whether the plugin is disabled.
if [[ -f "${plugin_root_dir}/share/rbenv/bundler/disabled" ]]; then
    plugin_disabled="1"
else
    plugin_disabled=""
fi
