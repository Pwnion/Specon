require('dotenv').config()

const { onRequest } = require("firebase-functions/v2/https");
const { Firestore } = require('@examind/ltijs-firestore');
const path = require('path')
const lti = require('ltijs').Provider

const canvasUrl = 'https://canvas.ngrok.app';

lti.setup(process.env.LTI_KEY,
  {
    plugin: new Firestore({collectionPrefix: 'lti/index/'})
  }, {
  staticPath: path.join(__dirname, './public'),
  cookies: {
    secure: true,
    sameSite: 'None'
  },
  tokenMaxAge: 30
})

lti.whitelist(lti.appRoute())

lti.onConnect(async (token, req, res) => {
  return res.sendFile(path.join(__dirname, './public/index.html'));
})

const setup = async () => {
  await lti.deploy({ serverless: true })
  await lti.registerPlatform({
    url: 'https://canvas.instructure.com',
    name: 'Specon',
    clientId: '10000000000001',
    authenticationEndpoint: `${canvasUrl}/api/lti/authorize_redirect`,
    accesstokenEndpoint: `${canvasUrl}/login/oauth2/token`,
    authConfig: { method: 'JWK_SET', key: `${canvasUrl}/api/lti/security/jwks` }
  })
}

setup();

exports.lti = onRequest(
  { region: 'australia-southeast2', cors: true },
  lti.app
);