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
module.exports = (robot) ->
  auth =
    admin_id: process.env.HUBOT_FB_ADMIN_ID || '27223964'
    app_id: process.env.HUBOT_FB_APP_ID || '364157406939543'
    app_secret: process.env.HUBOT_FB_APP_SECRET || "ce9779873babc764c3e07efb24a34e69"
    access_token: process.env.HUBOT_FB_WEMBLI_TOKEN || "CAAEeP12V3jwBAMhoO88EJNj4HpwJ1ApRz7dttdNjUGj0FJL2ZCl8nHuWGVcOlap1z2IXJvJwGuLz4WurkiVg3hxcae7dByPoQt9qiRMEenfhKdUyZCGZAfQBt8jYvCB9dkYvlmrdoK0cPhJTHg76CsIZAqdt742mnP2sM2aDj2OekRenbiTGgTREX7n4ZClTrvEK65aOPjwZDZD"
    page_id: process.env.HUBOT_FB_WEMBLI_PAGE_ID || "283576331690548"

  FB.setAccessToken auth.access_token

  robot.router.all '/callback/facebook', (req, res) ->
    console.log(req.params)
    res.send 'OK'

  robot.respond /wembli facebook post (\S+)\s(\S+)\s(.*)/i, (msg) ->
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


#params =
#  client_id: auth.app_id
#  client_secret: auth.app_secret
#  grant_type: 'client_credentials'
#
#FB.api 'oauth/access_token', params, (res) ->
#  console.log(res)
#  delete params.grant_type
#  params.redirect_uri = 'http://www.wembli.com:8080/callback/facebook'
#  params.code = res.access_token
#
#  FB.api 'oauth/access_tokan', params, (res) ->
#    console.log(res)
#
#    FB.setAccessToken(res.access_token)
#
#    FB.api auth.admin_id+'/accounts', (res) ->
#      console.log(res)
#      FB.setAccessToken res.access_token
#      params =
#        link: msg.match[1]
#        message: msg.match[2]
#        published: false
#
#      params.actions =
#        name: 'View'
#        link: msg.match[1]
#
#      FB.api auth.page_id + '/feed', 'post', params, (res) ->
#        if !res || res.error
#          console.log(res)
#          return
#        msg.send "wembli facebook " + res.id

