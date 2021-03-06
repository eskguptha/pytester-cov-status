Copyright (c) 2021, Santhosh Emmadi

# pytester-cov

[![made-with-python](https://img.shields.io/badge/Made%20with-Python-1f425f.svg)](https://www.python.org)


Enforce minimum pytest coverage by individual files, total, or both. Option to exclude directories and files as well.

## Python Packages Used

- [`pytest`](https://pypi.org/project/pytest/)
- [`pytest-cov`](https://pypi.org/project/pytest-cov/)

## Optional Inputs

- `pytest-root-dir`
  - root directory to recursively search for .py files
  - by default `pytest --cov` does not run recursively, but will here
- `pytest-tests-dir`
  - directory with pytest tests
  - if left empty will identify test(s) dir by default
- `requirements-file`
  - requirements filepath for project
  - if left empty will default to `requirements.txt`
  - necessary to install requirements to run `pytest` inside action
- `cov-omit-list`
  - list of directories and/or files to ignore
- `cov-threshold-total`
  - fail if the total coverage is less than threshold

## Outputs

- `output-table`
  - str
  - `pytest --cov` markdown output table
- `cov-threshold-total-fail`
  - boolean
  - `false` if total coverage less than `cov-threshold-total`, else `true`


```yaml
# **************************************************************************************************************** #
# This workflow will install Python dependencies, and run `pytest --cov` on all files recursively from the `pytest-root-dir`
# The workflow is also configured to exit with error if minimum individual file or total pytest coverage minimum not met
# If the workflow exits with error, an informative issue is created for the repo alerting the user
# If the workflow succeeds, a commit message is generated with the `pytest --cov` markdown table
#
# Variables to set:
#   * pytester action:
#     * pytest-root-dir: top-level directory to recursively check all .py files for `pytest --cov`
#     * cov-omit-list: comma separated str of all files and/or dirs to ignore
#   * env:
#     * COVERAGE_SINGLE: minimum individual file coverage required
#     * COVERAGE_TOTAL: minimum total coverage required
#
# Action outputs:
#   * output-table: `pytest --cov` markdown output table
#   * cov-threshold-total-fail: `false` if total coverage less than `cov-threshold-total`, else `true`
#
# Workflows used:
#   * actions/checkout@v2: checkout files to perform additional actions on
#   * eskguptha/pytester-cov@master: runs `pytest --cov` and associated functions

# **************************************************************************************************************** #

name: pytester-cov workflow

on: [push, pull_request]

jobs:
  build:

    runs-on: ubuntu-latest
    env:
      COVERAGE_TOTAL: 60

    steps:
    - uses: actions/checkout@v2
    - name: Set up Python 3.9
      uses: actions/setup-python@v2
      with:
        python-version: 3.9
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip fastapi json-logging gunicorn autopep8 pylint pytest requests pytest-cov pytest-mock python-dotenv pytest-bdd 
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

    - name: pytester-cov
      id: pytester-cov
      uses: eskguptha/pytester-cov@main
      with:
        pytest-root-dir: '.'
        cov-omit-list: 'test/*, temp/main3.py, temp/main4.py'
        cov-threshold-total: ${{ env.COVERAGE_TOTAL }}

    - name: Coverage total fail - new issue
      if: ${{ steps.pytester-cov.outputs.cov-threshold-total-fail == 'true' }}
      uses: nashmaniac/create-issue-action@v1.1
      with:
        title: Pytest coverage total falls below minimum ${{ env.COVERAGE_TOTAL }}
        token: ${{secrets.GITHUB_TOKEN}}
        assignees: ${{github.actor}}
        labels: workflow-failed
        body: ${{ steps.pytester-cov.outputs.output-table }}

    - name: Coverage total fail - exit
      if: ${{ steps.pytester-cov.outputs.cov-threshold-total-fail == 'true' }}
      run: |
        echo "cov Total fail ${{ steps.pytester-cov.outputs.cov-threshold-total-fail }}"
        exit 1

```

# Reference Link
https://github.com/alexanderdamiani/pytester-cov
