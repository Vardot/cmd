#!/usr/bin/env bash

################################################################################
## Vardot Workspace — tool installer
################################################################################
## Installs (or verifies) everything the Vardot Workspace needs on a fresh
## machine: git, gh, curl, wget, jq, rsync, unzip, python3, gawk, Node.js
## (npm + npx, which also powers the skills.sh CLI), Docker, DDEV and
## gitlab-ci-local. Idempotent: whatever is already installed is left alone.
##
##   bash <(wget -O - https://raw.githubusercontent.com/vardot/cmd/main/workspace/install-tools.sh)
##
##   --check   report what is present and what is missing, install nothing
##   -y        install everything missing without asking per group
##
## Linux: Debian/Ubuntu (apt) and Fedora (dnf). macOS: Homebrew. Windows: run
## it inside WSL2 (it tells you how when it detects native Windows).
################################################################################

set -u ;

CHECK_ONLY='no';
ASSUME_YES='no';
for arg in "$@"; do
  case "${arg}" in
    --check) CHECK_ONLY='yes' ;;
    -y|--yes) ASSUME_YES='yes' ;;
    -h|--help)
      sed -n '3,19p' "$0" 2>/dev/null || true ;
      echo "Usage: install.sh [--check] [-y]" ;
      exit 0 ;;
  esac
done

# ---------------------------------------------------------------- platform ---
OS='';
PKG='';
case "$(uname -s)" in
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null ; then
      echo "WSL detected — treating it as Linux. Docker Desktop's WSL2 backend also works.";
    fi
    if command -v apt-get > /dev/null 2>&1 ; then PKG='apt';
    elif command -v dnf > /dev/null 2>&1 ; then PKG='dnf';
    else
      echo "No apt or dnf here. Install the tools below with your package manager, then re-run --check.";
    fi
    OS='linux' ;;
  Darwin)
    OS='mac';
    PKG='brew';
    if ! command -v brew > /dev/null 2>&1 ; then
      echo "Homebrew is how everything installs on macOS and it is missing.";
      echo "  Install it first:  https://brew.sh";
      echo "  Then re-run this script.";
      [ "${CHECK_ONLY}" == 'yes' ] || exit 1 ;
    fi ;;
  MINGW*|MSYS*|CYGWIN*)
    echo "Native Windows shell detected. The workspace runs in WSL2:";
    echo "  1. In an admin PowerShell:  wsl --install -d Ubuntu";
    echo "  2. Reboot, open Ubuntu, and re-run this command there.";
    echo "  3. Install Docker Desktop for Windows and enable its WSL2 backend.";
    exit 1 ;;
  *)
    echo "Unrecognised platform '$(uname -s)' — install the tools manually, then re-run --check.";
    exit 1 ;;
esac

SUDO='';
if [ "${OS}" == 'linux' ] && [ "$(id -u)" != '0' ] ; then SUDO='sudo'; fi

# ------------------------------------------------------------------ helpers --
MISSING=();

function have() { command -v "$1" > /dev/null 2>&1 ; }

function report() {
  local tool="$1" how="$2";
  if have "${tool}" ; then
    printf '  ✓ %-16s %s\n' "${tool}" "$(command -v "${tool}")" ;
  else
    printf '  ✗ %-16s missing  (%s)\n' "${tool}" "${how}" ;
    MISSING+=("${tool}") ;
  fi
}

function confirm() {
  [ "${ASSUME_YES}" == 'yes' ] && return 0 ;
  local answer;
  read -r -p "$1 [y/N] " answer ;
  [ "${answer}" == 'y' ] || [ "${answer}" == 'Y' ] ;
}

function pkg_install() {
  case "${PKG}" in
    apt)  ${SUDO} apt-get update -qq && ${SUDO} apt-get install -y "$@" ;;
    dnf)  ${SUDO} dnf install -y "$@" ;;
    brew) brew install "$@" ;;
    *)    echo "  install manually: $*" ; return 1 ;;
  esac
}

# ------------------------------------------------------------------- survey --
echo "";
echo "Vardot Workspace tools on this ${OS} machine:";
echo "";
report git     "package manager";
report curl    "package manager";
report wget    "package manager";
report jq      "package manager";
report rsync   "package manager";
report unzip   "package manager";
report python3 "package manager";
report awk     "gawk via package manager";
report gh      "GitHub CLI — cli.github.com";
report node    "Node.js LTS — nodejs.org";
report npm     "ships with Node.js";
report npx     "ships with Node.js";
report docker  "get.docker.com / Docker Desktop";
report ddev    "ddev.com/install.sh";
report gitlab-ci-local "npm -g gitlab-ci-local";
echo "";
if have npx ; then
  echo "  ✓ skills.sh CLI    runs through npx (npx skills …), nothing to install";
else
  echo "  ✗ skills.sh CLI    needs npx (comes with Node.js)";
fi
echo "";

if [ "${#MISSING[@]}" -eq 0 ] ; then
  echo "Everything is here. Next: gh auth login, then clone github.com/Vardot/workspace (branch 1.0.x).";
  exit 0 ;
fi
if [ "${CHECK_ONLY}" == 'yes' ] ; then
  echo "Missing: ${MISSING[*]}   (re-run without --check to install)";
  exit 1 ;
fi

# ------------------------------------------------------------------ install --
function missing() {
  local tool;
  for tool in "${MISSING[@]}"; do [ "${tool}" == "$1" ] && return 0 ; done
  return 1 ;
}

base_pkgs=();
for tool in git curl wget jq rsync unzip python3 ; do
  missing "${tool}" && base_pkgs+=("${tool}") ;
done
missing awk && base_pkgs+=(gawk) ;
if [ "${#base_pkgs[@]}" -gt 0 ] && confirm "Install base tools (${base_pkgs[*]})?" ; then
  pkg_install "${base_pkgs[@]}" ;
fi

if missing gh && confirm "Install the GitHub CLI (gh)?" ; then
  case "${PKG}" in
    apt)
      # Debian/Ubuntu ship no gh package — this is the official keyring + repo.
      ${SUDO} mkdir -p /etc/apt/keyrings ;
      wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | ${SUDO} tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null ;
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | ${SUDO} tee /etc/apt/sources.list.d/github-cli.list > /dev/null ;
      ${SUDO} apt-get update -qq && ${SUDO} apt-get install -y gh ;;
    dnf)  ${SUDO} dnf install -y gh ;;
    brew) brew install gh ;;
  esac
fi

if missing node && confirm "Install Node.js LTS (brings npm, npx and the skills.sh CLI)?" ; then
  case "${PKG}" in
    apt)
      wget -qO- https://deb.nodesource.com/setup_lts.x | ${SUDO} bash - ;
      ${SUDO} apt-get install -y nodejs ;;
    dnf)  ${SUDO} dnf install -y nodejs npm ;;
    brew) brew install node ;;
  esac
fi

if missing docker && confirm "Install Docker?" ; then
  if [ "${OS}" == 'mac' ] ; then
    echo "  On macOS install Docker Desktop (or OrbStack):";
    echo "    brew install --cask docker      # or: brew install --cask orbstack";
    echo "  Start it once so the docker CLI works, then re-run --check.";
  else
    # Docker's official convenience script; adds the current user to the docker group after.
    wget -qO- https://get.docker.com | ${SUDO} sh ;
    if [ -n "${SUDO}" ] ; then
      ${SUDO} usermod -aG docker "$(id -un)" \
        && echo "  Added $(id -un) to the docker group — log out and back in for it to apply." ;
    fi
  fi
fi

if missing ddev && confirm "Install DDEV?" ; then
  # DDEV's official package repos — unlike ddev.com/install.sh these also work as root
  # (containers, CI) and get updated by the package manager afterwards.
  case "${PKG}" in
    apt)
      have gpg || ${SUDO} apt-get install -y gnupg ;
      ${SUDO} mkdir -p /etc/apt/keyrings ;
      wget -qO- https://pkg.ddev.com/apt/gpg.key | gpg --dearmor \
        | ${SUDO} tee /etc/apt/keyrings/ddev.gpg > /dev/null ;
      echo "deb [signed-by=/etc/apt/keyrings/ddev.gpg] https://pkg.ddev.com/apt/ * *" \
        | ${SUDO} tee /etc/apt/sources.list.d/ddev.list > /dev/null ;
      ${SUDO} apt-get update -qq && ${SUDO} apt-get install -y ddev ;;
    dnf)
      echo '[ddev]
name=ddev
baseurl=https://pkg.ddev.com/yum/
enabled=1
gpgcheck=0' | ${SUDO} tee /etc/yum.repos.d/ddev.repo > /dev/null ;
      ${SUDO} dnf install -y ddev ;;
    brew) brew install ddev/ddev/ddev ;;
  esac
fi

if missing gitlab-ci-local && have npm && confirm "Install gitlab-ci-local (runs .gitlab-ci.yml pipelines locally)?" ; then
  npm install -g gitlab-ci-local ;
fi

# ------------------------------------------------------------------- recheck --
echo "";
echo "Done. Re-checking:";
MISSING=();
for tool in git curl wget jq rsync unzip python3 awk gh node npm npx docker ddev gitlab-ci-local ; do
  report "${tool}" "see above" ;
done
echo "";
if [ "${#MISSING[@]}" -eq 0 ] ; then
  echo "All set. Next steps:";
else
  echo "Still missing: ${MISSING[*]} — see the notes above, then:";
fi
echo "  1. gh auth login";
echo "  2. Clone github.com/Vardot/workspace (branch 1.0.x) — its README takes it from there.";
