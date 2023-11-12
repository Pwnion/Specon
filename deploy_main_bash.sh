#!/bin/bash
flutter build web
rm -rf functions/public
mkdir functions/public
cp -r build/web/. functions/public
firebase deploy --only hosting:special-consideration,functions