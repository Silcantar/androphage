#!/usr/bin/env bash

git submodule init
git submodule update
python -m venv .venv
source .venv/bin/activate
pip install -e .