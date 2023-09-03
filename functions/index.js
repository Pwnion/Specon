require('dotenv').config()

const { onRequest } = require('firebase-functions/v2/https');
const { Firestore } = require('@examind/ltijs-firestore');

const express = require('express');
const path = require('path')
const lti = require('ltijs').Provider

exports.app = onRequest((req, res) => {
  console.log(req);

  lti.setup('wYtQ6kbYTcneSfHzjJ1YGAL6svNVzJCOzPG6R7lkCjolfH9bw00naIQDSBYnbevu',
    { plugin: new Firestore({collectionPrefix: 'lti-'}) },
    {
      appRoute: '/',
      loginRoute: '/login',
      cookies: {
        secure: false, // Set secure to true if the testing platform is in a different domain and https is being used
        sameSite: '' // Set sameSite to 'None' if the testing platform is in a different domain and https is being used
      },
      devMode: true // Set DevMode to false if running in a production environment with https
    }
  )
  
  lti.onConnect((token, req, _) => {
    console.log(token)
    return res.send(':)')
  })
  
  const setup = async () => {
    await lti.deploy({ port: process.env.PORT })
  
    // Register platform
    await lti.registerPlatform({
      url: 'https://8639-220-253-28-136.ngrok-free.app',
      name: 'ngrok-free',
      clientId: '10000000000001',
      authenticationEndpoint: 'https://8639-220-253-28-136.ngrok-free.app/api/lti/authorize_redirect',
      // accesstokenEndpoint: 'https://platform.url/token',
      authConfig: { method: 'JWK_SET', key: 'https://sso.canvaslms.com/api/lti/security/jwks' }
    })
  }
});
