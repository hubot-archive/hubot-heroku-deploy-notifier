# Description
#   A hubot script that notifies of heroku app deploys
#
# Configuration:
#   HUBOT_HEROKU_DEPLOY_ROOM - Room where notifications are dropped (optional)
#
# Commands:
#   None.
#
# URLS:
#   POST /hubot/heroku-deploys[?room=<room>]
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   patcon@gittip

url = require('url')
qs  = require('querystring')

module.exports = (robot) ->
  robot.router.post "/hubot/heroku-deploys", (req, res) ->
    query = qs.parse(url.parse(req.url).query)

    data = req.body
    room = query.room or process.env["HUBOT_HEROKU_DEPLOY_ROOM"]

    console.log data
