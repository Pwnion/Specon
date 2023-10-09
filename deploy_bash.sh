#!/bin/bash
flutter build web
rm -rf functions/public
mkdir functions/public
mv -f build/web/{.[!.],}* functions/public/
firebase deploy --only functions,hosting