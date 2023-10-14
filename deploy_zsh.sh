#!/bin/zsh
flutter build web
rm -rf functions/public
mkdir functions/public
mv -f build/web/*(D) functions/public/
firebase deploy --only functions