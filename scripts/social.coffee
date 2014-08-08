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
  app_secret: process.env.HUBOT_FB_APP_SECRET || "ce9779873babc764c3e07efb24a34e69"
  access_token: process.env.HUBOT_FB_WEMBLI_TOKEN || "CAAEeP12V3jwBAMhoO88EJNj4HpwJ1ApRz7dttdNjUGj0FJL2ZCl8nHuWGVcOlap1z2IXJvJwGuLz4WurkiVg3hxcae7dByPoQt9qiRMEenfhKdUyZCGZAfQBt8jYvCB9dkYvlmrdoK0cPhJTHg76CsIZAqdt742mnP2sM2aDj2OekRenbiTGgTREX7n4ZClTrvEK65aOPjwZDZD"
  page_id: process.env.HUBOT_FB_WEMBLI_PAGE_ID || "283576331690548"

redirectUri = 'http://www01.wembli.com:8080/callback/facebook/post'

module.exports = (robot) ->


  robot.router.get "/wot", (req,res) ->
    res.end "WOT"

  robot.router.get "/callback/facebook/post/:id", (req, res) ->
    console.log req.query
    console.log req.params
    if req.query.code
      params =
        client_id: auth.app_id,
        client_secret: auth.app_secret,
        redirect_url: redirectUri+'/'+req.param.id,
        code: req.query.code

      FB.api 'oauth/access_token', params, (res) ->
        console.log(res)

    if req.query.access_token
      FB.setAccessToken req.query.access_token
      console.log "get data for: "+req.param.id

      link = robot.brain.get(1+'-'+req.param.id)
      text = robot.brain.get(2+'-'+req.param.id)
      FB.api auth.admin_id+'/accounts', (res) ->
        console.log(res)
        FB.setAccessToken res.access_token
        params =
          link: link
          message: text
          published: false

        FB.api auth.page_id + '/feed', 'post', params, (res) ->
          if !res || res.error
            console.log(res)
            return
          msg.send "wembli facebook " + res.id

    FB.setAccessToken msg.match[1]
    params =
      link: msg.match[2]
      message: msg.match[3]
      published: false

    console.log params
    FB.api auth.page_id + '/feed', 'post', params, (res) ->
      if !res || res.error
        console.log(res)
        return
      msg.send "created post: http://www.facebook.com/wemblifan/posts/" + res.id.split('_')[1]


    res.end "OK"

  robot.respond /wembli facebook post (\S+)\s(.*)/i, (msg) ->
    rand = Math.random * 10 + 1
    id = parseInt rand
    console.log id

    storeParam(i, param) ->
      k = i + '-' + id
      console.log "storing "+k+" - "+param
      robot.brain.set k, param

    storeParam i, param for param, i in msg.match

    params =
      cliend_id: auth.app_id
      redirect_uri: redirectUri+'/'+id

    FB.api 'oauth/authorize', params, (res) ->
      console.log(res)





