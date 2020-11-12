const { createPrivateKey } = require("crypto")
const express = require("express")
const passport = require('passport')

const app = express()

app.use(passport.initialize())
app.use(passport.session())

app.get('/', (req, res) => res.sendFile('auth.html', { root: __dirname }))
app.get('/success', (req, res) => res.send('You have successfully logged in'))
app.get('/error', (req, res) => res.send('You failed miserably'))

passport.serializeUser((user, cb) => cb(null, user))
passport.deserializeUser((obj, cb) => cb(null, obj))


const port = process.env.PORT || 3000
app.listen(port, () => console.log('App listening on port ' + port + ' for directory ' + __dirname))

// Facebook

const FacebookStrategy = require('passport-facebook').Strategy
const FACEBOOK_APP_ID = '' + process.env.FACEBOOK_APP_ID
const FACEBOOK_APP_SECRET = '' + process.env.FACEBOOK_APP_SECRET

console.log(FACEBOOK_APP_ID + ' ' + FACEBOOK_APP_SECRET)

passport.use(new FacebookStrategy({
        clientID: FACEBOOK_APP_ID,
        clientSecret: FACEBOOK_APP_SECRET,
        callbackURL: '/auth/facebook/callback'
    },
    (accessToken, refreshToken, profile, cb) => cb(null, profile)
))

app.get('/auth/facebook',
    passport.authenticate('facebook'))

app.get('/auth/facebook/callback',
    passport.authenticate('facebook', { failureRedirect: '/error' }),
    (req, res) => res.redirect('/success'))
