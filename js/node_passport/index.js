// https://www.sitepoint.com/passport-authentication-for-nodejs-applications/
// https://www.digitalocean.com/community/tutorials/api-authentication-with-json-web-tokensjwt-and-passport

const express = require("express")
const flash = require('connect-flash');
const passport = require('passport')
const jwt = require('jsonwebtoken')

const app = express()

app.use(passport.initialize())
app.use(passport.session())


app.get('/', (req, res) => res.sendFile('auth.html', { root: __dirname }))
app.get('/success', (req, res) => res.send('You have successfully logged in at ' + JSON.stringify(Object.keys(res))))
app.get('/error', (req, res) => res.send('You failed miserably'))

passport.serializeUser((user, cb) => cb(null, user))
passport.deserializeUser((obj, cb) => cb(null, obj))


const port = process.env.PORT || 3000
app.listen(port, () => console.log('App listening on port ' + port + ' for directory ' + __dirname))

// Facebook

const FacebookStrategy = require('passport-facebook').Strategy
const FACEBOOK_APP_ID = '' + process.env.FACEBOOK_APP_ID
const FACEBOOK_APP_SECRET = '' + process.env.FACEBOOK_APP_SECRET

// console.log(FACEBOOK_APP_ID + ' ' + FACEBOOK_APP_SECRET)

passport.use(new FacebookStrategy({
        clientID: FACEBOOK_APP_ID,
        clientSecret: FACEBOOK_APP_SECRET,
        callbackURL: '/auth/facebook/callback_no_session'
    },
    (accessToken, refreshToken, profile, cb) => cb(null, profile)
))

app.get('/auth/facebook',
    passport.authenticate('facebook'))

app.get('/auth/facebook/callback',
    passport.authenticate('facebook', { 
        failureRedirect: '/error'
     }),
    (req, res) => res.redirect('/success'))

app.get('/auth/facebook/callback_no_session',
    passport.authenticate('facebook', { 
        failureRedirect: '/error'
     }),
    (req, res) => res.json({ 
        id: req.user.id, 
        username: req.user.displayName, 
        email: req.user.email,
        user: req.user, 
        authinfo: req['authInfo'],
        session: req.session,
        token: jwt.sign({ user: { _id: '' + req.user.id, name: req.user.displayName } }, 'TOP_SECRET'),
        keys: Object.keys(req)
     }))

// secure routes

const pjwt = require('passport-jwt')

passport.use(
    new pjwt.Strategy(
        {
            secretOrKey: 'TOP_SECRET',
            jwtFromRequest: (req) => {
                console.log('Got request as ' + JSON.stringify(req.query))
                return req.query.token
            }
        },
        async (token, done) => {
            try {
                return done(null, token.user)
            } catch (error) {
                console.log('Authent error with token = ' + token)
                done(error)
            }
        }
    )
)

const secureRoute = express.Router()

secureRoute.get('/profile',
        (req, res, next) => {
            res.json({
                message: 'You made it to the secure route',
                user: req.user,
                token: req.query.token
            })
        }
)

app.use('/user',
    passport.authenticate('jwt', { session: false }), 
    secureRoute
)
