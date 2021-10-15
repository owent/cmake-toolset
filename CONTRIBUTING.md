# Contributing to cmake-toolset

## Development

Code is formatted automatically and enforced by CI.

### Build and Run Code Examples

```sh
mkdir -p test/build_jobs_dir
cd test/build_jobs_dir
cmake .. -DATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_LOW_MEMORY_MODE=ON
cmake --build . -j
ctest . -V
```

## Pull Requests

### How to Send Pull Requests

Everyone is welcome to contribute code to `cmake-toolset` via GitHub pull
requests (PRs).

To create a new PR, fork the project in GitHub and clone the upstream repo:

```sh
git clone --recursive https://github.com/atframework/cmake-toolset.git
```

Add your fork as a remote:

```sh
git remote add fork https://github.com/YOUR_GITHUB_USERNAME/cmake-toolset.git
```

Check out a new branch, make modifications and push the branch to your fork:

```sh
git checkout -b feature
# edit files
ci/format.sh
git commit
git push fork feature
```

Open a pull request against the main `cmake-toolset` repo.

To run tests locally, please read the [ci/do_ci.sh](ci/do_ci.sh) and [ci/do_ci.sh](ci/do_ci.ps1) .
