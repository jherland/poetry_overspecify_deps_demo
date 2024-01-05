# Demonstrate "over-specifying" dependencies in a Poetry project

Here is an example project that work with Python >= v3.7.

It has one dependency, `setuptools`, specified as `>=68.0.0`.

`setuptools` itself dropped support for Python 3.7 in v68.1.0, hence, as of
this writing, the latest versions of setuptools are:
- v69.0.3 (for Python >= 3.8)
- v68.0.0 (for Python < 3.8)

For this project, we would expect Poetry to:
- install setuptools v69.0.3 when running under Python >=3.8
- install setuptools v68.0.0 when running under Python v3.7

This is not what we're seeing, Instead, Poetry chooses to install setuptools
v68.0.0 for _all_ Python versions.

This issue was discovered/discussed in
[https://github.com/tweag/FawltyDeps/pull/409].

## Workaround: "Over-specify" the setuptools dependency

By applying this diff to `pyproject.toml`:

```diff
-setuptools = ">=68.0.0"
+setuptools = [
+    # setuptools 68.1.0 drops support for Python v3.7:
+    {version = ">=68.0.0", python = ">=3.8"},
+    {version = ">=68.0.0,<68.1.0", python = "<3.8"},
+]
```

we are not really _changing_ anything, AFAICS: The `>=68.0.0` constraint is
still present for all Python versions, and the added `<68.1.0` constraint for
Python <3.8 should already be apparent from looking at setuptools' own
metadata.

Even so, this does in fact "fix" the issue for Poetry, as it is now able to
install setuptools according to our expectations above.

## To demonstrate this issue

If you have Nix available, run `nix-shell` to launch a shell with Poetry v1.7.1
and all necessary Python versions.

Run `nox` to install the project w/deps on each supported Python version and
print the versions on the resulting virtualenvs.

Observed behavior:
- Before the last commit: setuptools v68.0.0 is installed for all Python
  version. This is _not_ what we want.
- After the last commit (which "over-specifies" the setuptools dependency):
  setuptools v68.0.0 is installed for Python v3.7, setuptools v69.0.3 is
  installed for all newer Python versions.

