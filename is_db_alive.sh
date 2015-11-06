#!/bin/bash
while ! nc -z $1  5432; do sleep 3; done