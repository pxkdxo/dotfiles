#!/usr/bin/env python3
"""Log into existing AWS IAM Identity Center and Databricks OAuth profiles."""

import argparse
import configparser
import os
import shlex
import shutil
import signal
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class CLI:
    config_env: str
    config_path: str
    profile_env: tuple[str, ...]
    default_profile: str
    login_args: tuple[str, ...]
    cached_args: tuple[str, ...]


CLIS = {
    "aws": CLI(
        config_env="AWS_CONFIG_FILE",
        config_path="~/.aws/config",
        profile_env=("AWS_DEFAULT_PROFILE", "AWS_PROFILE"),
        default_profile="default",
        login_args=("sso", "login"),
        cached_args=(
            "configure",
            "export-credentials",
            "--no-cli-auto-prompt",
            "--no-cli-pager",
        ),
    ),
    "databricks": CLI(
        config_env="DATABRICKS_CONFIG_FILE",
        config_path="~/.databrickscfg",
        profile_env=("DATABRICKS_CONFIG_PROFILE",),
        default_profile="DEFAULT",
        login_args=("auth", "login"),
        cached_args=("auth", "token"),
    ),
}


def databricks_value(value: str) -> str:
    if value.startswith(("'", '"', "`")):
        quoted, closing_quote, _ = value[1:].partition(value[0])
        if closing_quote:
            return quoted
    return value.partition("#")[0].partition(";")[0].rstrip()


def read_config(cli: str, path: Path) -> configparser.ConfigParser:
    # Databricks uses DEFAULT as a profile, so its values must stay in that section.
    config = configparser.ConfigParser(
        interpolation=None, default_section="", strict=cli == "aws"
    )
    try:
        with path.open(encoding="utf-8-sig") as stream:
            config.read_file(stream)
    except (configparser.Error, UnicodeError) as error:
        raise ValueError(f"Could not parse {path} as an INI file.") from error
    if cli == "databricks":
        for name in config.sections():
            for key, value in config.items(name):
                config[name][key] = databricks_value(value)
    return config


def profile_sections(
    cli: str, config: configparser.ConfigParser
) -> dict[str, configparser.SectionProxy]:
    if cli == "databricks":
        return {
            name: config[name] for name in config.sections() if name != "__settings__"
        }

    profiles: dict[str, configparser.SectionProxy] = {}
    for section in config.sections():
        if section == "default":
            profiles[section] = config[section]
        elif section.startswith("profile"):
            try:
                parts = shlex.split(section)
            except ValueError:
                continue
            if len(parts) == 2 and parts[0] == "profile" and parts[1]:
                profiles[parts[1]] = config[section]
    return profiles


def is_sso_profile(cli: str, section: configparser.SectionProxy) -> bool:
    if cli == "aws":
        return bool(section.get("sso_session") or section.get("sso_start_url"))

    if not section.get("host"):
        return False
    auth_type = section.get("auth_type")
    if auth_type:
        return auth_type == "databricks-cli"
    # A host-only profile can be signed in with OAuth. Preserve existing credentials.
    credential_fields = (
        "token",
        "username",
        "password",
        "client_secret",
        "azure_client_id",
        "azure_client_secret",
        "google_credentials",
        "google_service_account",
        "oidc_token_env",
        "oidc_token_filepath",
    )
    return not any(section.get(key) for key in credential_fields) and (
        section.get("azure_use_msi", "").lower() != "true"
    )


def select_profiles(
    args: argparse.Namespace, config: configparser.ConfigParser, path: Path
) -> dict[str, configparser.SectionProxy]:
    profiles = profile_sections(args.cli, config)
    if args.all:
        selected = {
            name: section
            for name, section in profiles.items()
            if is_sso_profile(args.cli, section)
        }
        if not selected:
            raise ValueError(f"No SSO profiles found in {path}.")
        return selected

    cli = CLIS[args.cli]
    name = args.profile
    if name is None:
        name = next(
            (os.environ[key] for key in cli.profile_env if os.environ.get(key)), None
        )
        if name is None and args.cli == "databricks":
            configured = config.get("__settings__", "default_profile", fallback="")
            if configured in profiles:
                name = configured
        if name is None:
            name = cli.default_profile

    if name not in profiles:
        raise ValueError(
            f"No profile named {name!r} in {path}. Use --profile or --all to select a configured profile."
        )
    if not is_sso_profile(args.cli, profiles[name]):
        raise ValueError(f"SSO is unavailable for profile {name!r} in {path}.")
    return {name: profiles[name]}


def log_in(
    args: argparse.Namespace,
    profiles: dict[str, configparser.SectionProxy],
    env: dict[str, str],
) -> int:
    executable = shutil.which(args.cli) if isinstance(args.cli, str) else None
    if executable is None:
        raise ValueError(f"The {args.cli} CLI is required on PATH.")
    cli = CLIS[args.cli]
    command = cli.cached_args if args.non_interactive else cli.login_args
    # The cache commands emit credentials on stdout. Their exit status is enough.
    stream = subprocess.DEVNULL if args.non_interactive else None
    failed = False
    for name, section in profiles.items():
        if (
            args.cli == "aws"
            and args.non_interactive
            and not (section.get("sso_account_id") and section.get("sso_role_name"))
        ):
            print(
                f"Non-interactive AWS login for {name!r} requires an SSO account ID and role.",
                file=sys.stderr,
            )
            failed = True
            continue

        if not args.non_interactive:
            print(
                f"Logging into {args.cli} profile {name!r}.",
                file=sys.stderr,
                flush=True,
            )
        result = subprocess.run(
            [executable, *command, f"--profile={name}"],
            env=env,
            stdin=stream,
            stdout=stream,
            check=False,
        )
        if result.returncode in (-signal.SIGINT, 130):
            return 130
        if result.returncode:
            action = "SSO credential check" if args.non_interactive else "Login"
            print(
                f"{action} failed for {args.cli} profile {name!r} (exit {result.returncode}).",
                file=sys.stderr,
            )
            failed = True
        elif args.non_interactive:
            print(
                f"{args.cli} profile {name!r} has usable credentials.", file=sys.stderr
            )
    return int(failed)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Log into CLI SSO profiles.",
        epilog=(
            "Uses the CLI's standard config file and default profile unless overridden. "
            "Non-interactive AWS login requires an SSO account ID and role."
        ),
    )
    parser.add_argument(
        "cli", choices=CLIS, metavar="CLI", help="CLI interface (aws or databricks)"
    )
    parser.add_argument(
        "-c", "--config", metavar="CONFIG_FILE", help="path to the CLI config file"
    )
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument(
        "-a", "--all", action="store_true", help="log into all configured SSO profiles"
    )
    selection.add_argument(
        "-p", "--profile", metavar="SSO_PROFILE", help="log into the named profile"
    )
    parser.add_argument(
        "-n",
        "--non-interactive",
        action="store_true",
        help="reuse or refresh cached credentials and fail if a browser sign-in is required",
    )
    args = parser.parse_args()

    cli = CLIS[args.cli]
    env = os.environ.copy()
    try:
        config_path = args.config or env.get(cli.config_env) or cli.config_path
        if args.cli == "aws":
            config_path = os.path.expandvars(config_path)
        path = Path(config_path).expanduser().absolute()
        env[cli.config_env] = str(path)
        config = read_config(args.cli, path)
        profiles = select_profiles(args, config, path)
        return log_in(args, profiles, env)
    except (OSError, ValueError) as error:
        print(f"{parser.prog}: {error}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        return 130


if __name__ == "__main__":
    sys.exit(main())
