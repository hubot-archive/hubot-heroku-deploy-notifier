# Description
#   A hubot script that notifies of heroku app deploys
#
# Configuration:
#   HUBOT_HEROKU_DEPLOY_ROOM     - Default room where notifications are dropped. (optional)
#   HUBOT_HEROKU_DEPLOY_TEMPLATE - Override the default mustache notification template. (optional)
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
#
# Author:
#   patcon@gittip

config =
  room:     process.env.HUBOT_HEROKU_DEPLOY_ROOM
  template: process.env.HUBOT_HEROKU_DEPLOY_TEMPLATE

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
    commits_msgs = data.git_log.replace(/^\*/, '').split(' *')

    first_message = commit_msgs[0]
    last_message  = commit_msgs[-1]

    # Missing GitHub Search API functionality
    first_commit = # Search for commit message in repo
    last_commit  = # Search for commit message in repo

    data.compare_url = "https://github.com/#{repo}/compare/#{first_commit}...#{last_commit}"

    message = Mustache.render template, data

    robot.messageRoom room, message

    # End the response? Not doc'd.
    res.end ""
