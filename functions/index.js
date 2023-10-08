require('dotenv').config()

const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { Firestore } = require('@examind/ltijs-firestore');
const { onRequest } = require("firebase-functions/v2/https");
const path = require('path')
const lti = require('ltijs').Provider
const express = require('express');

const canvasUrl = 'https://canvas.ngrok.app';
const ltiUrl = 'https://lti-tzff7thfsa-km.a.run.app'
const accessTokenEndpoint = `${canvasUrl}/login/oauth2/token`
const apiRedirectUri = `${ltiUrl}/code`
const ltiClientId = '10000000000001';
const apiClientId = '10000000000002';

const app = initializeApp();
const db = getFirestore(app);
const server = express();

const usersRef = db.collection('users');

lti.setup(process.env.LTI_KEY,
  {
    plugin: new Firestore({collectionPrefix: 'lti/index/'})
  }, {
  staticPath: path.join(__dirname, './public'),
  cookies: {
    secure: true,
    sameSite: 'None'
  },
  tokenMaxAge: 60
})
lti.whitelist(lti.appRoute());

lti.onConnect(async (token, req, res) => {
  if(!token) {
    return res.redirect(`/app`);
  }

  const canvasUid = token.user;
  const userRef = usersRef.doc(canvasUid);
  const userSnapshot = await userRef.get();
  if(userSnapshot.exists) {
    const userData = userSnapshot.data();
    const email = userData['email'];
    const refreshToken = userData['refresh_token'];
    const response = await fetch(accessTokenEndpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        grant_type: 'refresh_token',
        client_id: apiClientId,
        client_secret: process.env.API_KEY,
        refresh_token: refreshToken,
      })
    });
    const data = await response.json();
    const accessToken = data['access_token'];
    await userRef.update({'access_token': accessToken});
    return res.redirect(`/app?email=${email}`);
  } else {
    return res.redirect(`${canvasUrl}/login/oauth2/auth?client_id=${apiClientId}&response_type=code&state=${canvasUid}&redirect_uri=${apiRedirectUri}`);
  }
})

server.get('/code', async (req, res) => {
  const code = req.query.code;
  const canvasUid = req.query.state;
  const tokenResponse = await fetch(accessTokenEndpoint, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      grant_type: 'authorization_code',
      client_id: apiClientId,
      client_secret: process.env.API_KEY,
      redirect_uri: apiRedirectUri,
      code: code,
    })
  });
  const tokenData = await tokenResponse.json();
  const accessToken = tokenData['access_token'];
  const refreshToken = tokenData['refresh_token'];
  const accountId = tokenData['user']['id'];
  const apiResponse = await fetch(`${canvasUrl}/api/v1/users/${accountId}/profile`, {
    headers: {
      Authorization: `Bearer ${accessToken}`
    }
  });
  const apiData = await apiResponse.json();
  const email = apiData['login_id'];
  usersRef.doc(canvasUid).set({
    access_token: accessToken,
    refresh_token: refreshToken,
    account_id: accountId,
    email: email
  });

  return res.redirect(`/app?email=${email}`);
})

server.get('/app', async (req, res) => {
  return res.sendFile(path.join(__dirname, './public/index.html'));
})

const setup = async () => {
  await lti.deploy({ serverless: true })
  await lti.registerPlatform({
    url: 'https://canvas.instructure.com',
    name: 'Specon',
    clientId: ltiClientId,
    authenticationEndpoint: `${canvasUrl}/api/lti/authorize_redirect`,
    accesstokenEndpoint: accessTokenEndpoint,
    authConfig: { method: 'JWK_SET', key: `${canvasUrl}/api/lti/security/jwks` }
  })
}

setup();

server.use(lti.app);
exports.lti = onRequest(
  { region: 'australia-southeast2', cors: true },
  server
);