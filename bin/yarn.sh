install_yarn() {
  local dir="$build_dir/.heroku/yarn"
  # Look in package.json's engines.yarn field for a semver range
  local version=$($bp_dir/vendor/jq -r .engines.yarn $build_dir/package.json)

  if needs_resolution "$version"; then
    echo "Resolving yarn version ${version:-(latest)} via semver.io..."
    local version=$(curl --silent --get --retry 5 --retry-max-time 15 --data-urlencode "range=${version}" https://semver.herokuapp.com/yarn/resolve)
  fi

  echo "Downloading and installing yarn ($version)..."
  local download_url="https://yarnpkg.com/downloads/$version/yarn-v$version.tar.gz"
  local code=$(curl "$download_url" -L --silent --fail --retry 5 --retry-max-time 15 -o /tmp/yarn.tar.gz --write-out "%{http_code}")
  if [ "$code" != "200" ]; then
    echo "Unable to download yarn: $code" && false
  fi
  rm -rf $dir
  mkdir -p "$dir"
  # https://github.com/yarnpkg/yarn/issues/770
  if tar --version | grep -q 'gnu'; then
    tar xzf /tmp/yarn.tar.gz -C "$dir" --strip 1 --warning=no-unknown-keyword
  else
    tar xzf /tmp/yarn.tar.gz -C "$dir" --strip 1
  fi
  chmod +x $dir/bin/*

  PATH=$build_dir/.heroku/yarn/bin:$PATH

  echo "Installed yarn $(yarn --version)"
}
