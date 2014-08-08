# Description:
#   Post to wembli facebook page
#
# Dependencies:
#    "fb" : "https://github.com/Thuzi/facebook-node-sdk/"
#
# Configuration:
#   HUBOT_FB_APP_ID
#   HUBOT_FB_APP_SECRET
#   HUBOT_FB_WEMBLI_TOKEN
#   HUBOT_FB_WEMBLI_PAGE_ID
#
# Commands:
#   wembli facebook <link> <optional post message>
#
# Notes:
#   go here to get access token for wembli page:
#   https://developers.facebook.com/tools/explorer/314732478586428/?method=GET&path=me%2Faccounts&version=v2.1
# Author:
#   wembli

url = require 'url'
FB = require 'fb'

auth =
  admin_id: process.env.HUBOT_FB_ADMIN_ID || '27223964'
  app_id: process.env.HUBOT_FB_APP_ID || '314732478586428'
  app_secret: process.env.HUBOT_FB_APP_SECRET || "68b80c2adfd5421b6c9df85751264d4e"
  access_token: process.env.HUBOT_FB_WEMBLI_TOKEN || "CAAEeP12V3jwBAMhoO88EJNj4HpwJ1ApRz7dttdNjUGj0FJL2ZCl8nHuWGVcOlap1z2IXJvJwGuLz4WurkiVg3hxcae7dByPoQt9qiRMEenfhKdUyZCGZAfQBt8jYvCB9dkYvlmrdoK0cPhJTHg76CsIZAqdt742mnP2sM2aDj2OekRenbiTGgTREX7n4ZClTrvEK65aOPjwZDZD"
  page_id: process.env.HUBOT_FB_WEMBLI_PAGE_ID || "283576331690548"

redirectUri = 'http://www01.wembli.com:8080/callback/facebook/post'

module.exports = (robot) ->

  robot.on "facebook-post", (data) ->
    robot.send {user:robot.brain.userForId(data.user)}, data.result

  robot.router.get "/wot", (req,res) ->
    res.end "WOT"

  robot.router.get "/callback/facebook/post/:id", (req, res) ->
    if req.query.code
      params =
        client_id: auth.app_id,
        client_secret: auth.app_secret,
        redirect_uri: redirectUri+'/'+req.params['id'],
        code: req.query.code

      FB.api 'oauth/access_token', params, (res) ->
        FB.setAccessToken res.access_token

        publish = (robot.brain.get('1-'+req.params['id']) == 'publish')
        link = robot.brain.get('2-'+req.params['id'])
        text = robot.brain.get('3-'+req.params['id'])
        u = robot.brain.userForId(robot.brain.get(4+'-'+req.params['id']))
        if !u
          res.end "ERROR"

        FB.api auth.admin_id+'/accounts', (res) ->
          FB.setAccessToken res.data[0].access_token
          params =
            link: link,
            message: text,
            published: publish

          FB.api auth.page_id + '/feed', 'post', params, (res) ->
            if !res || res.error
              return
            text = "created post: http://www.facebook.com/wemblifan/posts/" + res.id.split('_')[1]

            robot.emit "facebook-post", {status:"OK", user: u.id, result:text}
	    res.end "OK"


  robot.respond /wembli (publish)?\s?facebook post\s+(http\S+)\s+(.*)/i, (msg) ->
    rand = Math.random() * 10 + 1
    id = parseInt rand

    robot.brain.set '1-'+id, msg.match[1]
    robot.brain.set '2-'+id, msg.match[2]
    robot.brain.set '3-'+id, msg.match[3]
    robot.brain.set '4-'+id, msg.message.user.id
    url = "http://www.facebook.com/dialog/oauth?client_id="+auth.app_id+'&redirect_uri='+redirectUri+'/'+id
    robot.http(url).get() (err, res, body) ->
      msg.send res.headers.location





