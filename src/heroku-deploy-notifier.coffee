# Description
#   A hubot script that notifies of heroku app deploys
#
# Configuration:
#   HUBOT_HEROKU_DEPLOY_ROOM     - Default room where notifications are dropped. (optional)
#   HUBOT_HEROKU_DEPLOY_TEMPLATE - Override the default mustache notification template. (optional)
#   HUBOT_HEROKU_DEPLOY_APIKEY   - Required for using the {{{compare_url}}} template var.
#   HUBOT_HEROKU_DEPLOY_REPO_MAP - Required for proper contruction of GitHub URLs. JSON hash. (See notes)
#
# Commands:
#   None.
#
# URLS:
#   POST /hubot/heroku-deploys[?room=<room>]
#
# Notes:
#   * Templating values are those available in the payload delivered from Heroku:
#   https://devcenter.heroku.com/articles/deploy-hooks#customizing-messages
#   * Keep in mind that all mustache vars are urlescaped by default. Use a
#   triple-mustache to skip urlescaping, like for {{{url}}}.
#   * {{{compare_url}}} var is only available if the Heroku API key and a
#   proper repo maps are provided.
#   * The HUBOT_HEROKU_DEPLOY_REPO_MAP should be in the following format:
#   '{"gittip": "gittip/www.gittip.com", "building-gittip-com": "gittip/building.gittip.com"}'
#
# Author:
#   patcon@gittip

config =
  room:          process.env.HUBOT_HEROKU_DEPLOY_ROOM
  template:      process.env.HUBOT_HEROKU_DEPLOY_TEMPLATE
  heroku_apikey: process.env.HUBOT_HEROKU_DEPLOY_APIKEY
  gh_repo_map:   JSON.parse process.env.HUBOT_HEROKU_DEPLOY_REPO_MAP

defaults =
  template: "App deployed to Heroku: {{app}}@{{head}}"
  room:     config.room

url      = require('url')
qs       = require('querystring')
Mustache = require('mustache')

module.exports = (robot) ->
  robot.router.post "/hubot/heroku-deploys", (req, res) ->
    uri = url.parse(req.url)
    query = qs.parse(uri.query)

    room = query.room or defaults.room
    template = config.template or defaults.template
    data = req.body

    # Generate a URL for comparing commits on GitHub
    if config.heroku_apikey? and config.gh_repo_map[data.app]?
      repo = config.gh_repo_map[data.app]
      robot.http("https://:#{config.heroku_apikey}@api.heroku.com/apps/#{data.app}/releases")
        .get() (err, res, body) ->
          if res.statusCode isnt 200
            robot.messageRoom room, "Heroku request failed: #{err}"
            return

          release_data = JSON.parse body
          last_commit = release_data[-1].commit[0..6]
          deploy_commit = data.head

          data.compare_url = "https://github.com/#{repo}/compare/#{last_commit}...#{deploy_commit}"

    message = Mustache.render template, data

    robot.messageRoom room, message

    # End the response? Not doc'd.
    res.end ""
