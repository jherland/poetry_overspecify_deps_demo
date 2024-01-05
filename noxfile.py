import hashlib
import sys
from pathlib import Path
from typing import Iterable

import nox

python_versions = ["3.7", "3.8", "3.9", "3.10", "3.11", "3.12"]


def install_self(session: nox.Session) -> None:
    """Install project + deps using requirements derived from poetry.lock.

    We cannot use `poetry install` directly here, because it ignores the
    session's virtualenv and installs into Poetry's own virtualenv. Instead, we
    use `poetry export` with suitable options to generate a requirements.txt
    file which we can then pass to session.install().
    """
    if isinstance(session.virtualenv, nox.virtualenv.PassthroughEnv):
        session.warn(
            "Running outside a Nox virtualenv! We will skip installation here, "
            "and simply assume that the necessary dependencies have already "
            "been installed by other means!"
        )
        return

    requirements_txt = Path(session.cache_dir, session.name, "reqs_from_poetry.txt")
    requirements_txt.parent.mkdir(parents=True, exist_ok=True)
    argv = ["poetry", "export", "--format=requirements.txt", f"--output={requirements_txt}"]
    session.run_always(*argv, external=True)

    session.install("-r", str(requirements_txt))
    session.install(".")


@nox.session(python=python_versions)
def test_version(session):
    install_self(session)
    session.run("pip", "list")
