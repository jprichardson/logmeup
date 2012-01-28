#!/usr/bin/env bash
NODE_ENV=testing mocha $(find test -name "*.test.coffee")