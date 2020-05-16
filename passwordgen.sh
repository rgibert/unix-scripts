#!/usr/bin/env bash

openssl rand -base64 32 | tr \!@\#$%^\&\*\(\)+=\\\/\“\' _ | tr Oo 0 | tr Ii 1 | tr B 8
