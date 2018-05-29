require 'twitch/request'
require 'twitch/adapters'

module Twitch
  class Client
    include Twitch::Request
    include Twitch::Adapters

    def initialize(options = {})
      @client_id = options[:client_id] || ""
      @secret_key = options[:secret_key] || ""
      @redirect_uri = options[:redirect_uri] || ""
      @scope = options[:scope] || []
      @access_token = options[:access_token] || nil

      @adapter = get_adapter(options[:adapter] || nil)

      @base_url = "https://api.twitch.tv/kraken"
      @alt_base_url = "https://api.twitch.tv/api"
    end

    attr_reader :base_url, :redirect_url, :scope
    attr_accessor :adapter

    public

    def adapter=(adapter)
      get_adapter(adapter)
    end

    def link
      scope = ""
      @scope.each { |s| scope += s + '+' }
      "#{@base_url}/oauth2/authorize?response_type=code&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}&scope=#{scope}"
    end

    def auth(code)
      path = "/oauth2/token"
      url = @base_url + path
      post(url, {
        :client_id => @client_id,
        :client_secret => @secret_key,
        :grant_type => "authorization_code",
        :redirect_uri => @redirect_uri,
        :code => code
      })
    end

    # User

    def user(user_id = nil)
      return your_user unless user_id

      path = "/users/"
      url = @base_url + path + user_id

      get(url)
    end

    def users_by_usernames(usernames = [])
      path = "/users/"
      usernames = (usernames.map { |username| CGI.escape(username) }).join(",")
      url = @base_url + path + "?login=" + usernames

      get(url)
    end

    def your_user
      return false unless @access_token

      path = "/user?oauth_token=#{@access_token}"
      url = @base_url + path

      get(url)
    end

    # Teams

    def teams
      path = "/teams/"
      url = @base_url + path

      get(url)
    end


    def team(team_id)
      path = "/teams/"
      url = @base_url + path + team_id

      get(url)
    end

    # Channel

    def channel(channel_id = nil)
      return your_channel unless channel_id

      path = "/channels/"
      url = @base_url + path + channel_id

      get(url)
    end

    def channel_panels(channel_id = nil)
      return nil if channel_id.nil?

      path = "/channels/#{channel_id}/panels"
      url = @alt_base_url + path

      get(url)
    end

    def your_channel
      return false unless @access_token

      path = "/channel?oauth_token=#{@access_token}"
      url = @base_url + path

      get(url)
    end

    def editors(channel_id)
      return false unless @access_token

      path = "/channels/#{channel_id}/editors?oauth_token=#{@access_token}"
      url = @base_url + path

      get(url)
    end

    # TODO: Add ability to set delay, which is only available for partered channels
    def edit_channel(channel_id, status, game)
      return false unless @access_token

      path = "/channels/#{channel_id}/?oauth_token=#{@access_token}"
      url = @base_url + path
      data = {
        :channel =>{
          :game => game,
          :status => status
        }
      }
      put(url, data)
    end

    def reset_key(channel_id)
      return false unless @access_token

      path = "/channels/#{channel_id}/stream_key?oauth_token=#{@access_token}"
      url = @base_url + path
      delete(url)
    end

    def follow_channel(user_id, channel_id, notifications = nil)
      return false unless @access_token

      path = "/users/#{user_id}/follows/channels/#{channel_id}?oauth_token=#{@access_token}"
      notifications_suffix = notifications.nil? ? "" : "&notifications=#{!!notifications}"
      url = @base_url + path + notifications_suffix
      put(url)
    end

    def unfollow_channel(user_id, channel_id)
      return false unless @access_token

      path = "/users/#{user_id}/follows/channels/#{channel_id}?oauth_token=#{@access_token}"
      url = @base_url + path
      delete(url)
    end

    def run_commercial(channel_id, length = 30)
      return false unless @access_token

      path = "/channels/#{channel_id}/commercial?oauth_token=#{@access_token}"
      url = @base_url + path
      post(url, {
        :length => length
      })
    end

    def channel_teams(channel_id)
      return false unless @access_token

      path = "/channels/#{channel_id}/teams?oauth_token=#{@access_token}"
      url = @base_url + path

      get(url)
    end

    # Streams

    def stream(stream_name)
      path = "/streams/#{stream_name}"
      url = @base_url + path

      get(url)
    end

    def streams(options = {})
      query = build_query_string(options)
      path = "/streams"
      url =  @base_url + path + query

      get(url)
    end

    def featured_streams(options = {})
      query = build_query_string(options)
      path = "/streams/featured"
      url = @base_url + path + query

      get(url)
    end

    def summarized_streams(options = {})
      query = build_query_string(options)
      path = "/streams/summary"
      url = @base_url + path + query

      get(url)
    end

    def followed_streams(options = {})
      return false unless @access_token

      options[:oauth_token] = @access_token
      query = build_query_string(options)
      path = "/streams/followed"
      url = @base_url + path + query

      get(url)
    end
    alias :your_followed_streams :followed_streams

    #Games

    def top_games(options = {})
      query = build_query_string(options)
      path = "/games/top"
      url = @base_url + path + query

      get(url)
    end

    #Search

    def search_channels(options = {})
      query = build_query_string(options)
      path = "/search/channels"
      url = @base_url + path + query

      get(url)
    end

    def search_streams(options = {})
      query = build_query_string(options)
      path = "/search/streams"
      url = @base_url + path + query

      get(url)
    end

    def search_games(options = {})
      query = build_query_string(options)
      path = "/search/games"
      url = @base_url + path + query

      get(url)
    end

    # Videos

    def channel_videos(channel_id, options = {})
      query = build_query_string(options)
      path = "/channels/#{channel_id}/videos"
      url = @base_url + path + query

      get(url)
    end

    def video(video_id)
      path = "/videos/#{video_id}/"
      url = @base_url + path

      get(url)
    end

    def subscribed?(user_id, channel_id, options = {})
      options[:oauth_token] = @access_token
      query = build_query_string(options)
      path = "/users/#{user_id}/subscriptions/#{channel_id}"
      url = @base_url + path + query

      get(url)
    end

    def followed_videos(options ={})
      return false unless @access_token

      options[:oauth_token] = @access_token
      query = build_query_string(options)
      path = "/videos/followed"
      url = @base_url + path + query

      get(url)
    end
    alias :your_followed_videos :followed_videos

    def top_videos(options = {})
      query = build_query_string(options)
      path = "/videos/top"
      url = @base_url + path + query

      get(url)
    end

    # Blocks

    def blocks(user_id, options = {})
      options[:oauth_token] = @access_token
      query = build_query_string(options)
      path = "/users/#{user_id}/blocks"
      url = @base_url + path + query

      get(url)
    end

    def block_user(user_id, target)
      return false unless @access_token

      path = "/users/#{user_id}/blocks/#{target}?oauth_token=#{@access_token}"
      url = @base_url + path
      put(url)
    end

    def unblock_user(user_id, target)
      return false unless @access_token

      path = "/users/#{user_id}/blocks/#{target}?oauth_token=#{@access_token}"
      url = @base_url + path
      delete(url)
    end

    # Chat

    def chat_links(channel_id)
      path = "/chat/"
      url = @base_url + path + channel_id

      get(url)
    end

    def badges(channel_id)
      path = "/chat/#{channel_id}/badges"
      url = @base_url + path

      get(url)
    end

    def emoticons()
      path = "/chat/emoticons"
      url = @base_url + path

      get(url)
    end

    # Follows

    def following(channel_id, options = {})
      query = build_query_string(options)
      path = "/channels/#{channel_id}/follows"
      url = @base_url + path + query

      get(url)
    end

    def followed(user_id, options = {})
      query = build_query_string(options)
      path = "/users/#{user_id}/follows/channels"
      url = @base_url + path + query

      get(url)
    end

    def follow_status(user_id, channel_id)
      path = "/users/#{user_id}/follows/channels/#{channel_id}/?oauth_token=#{@access_token}"
      url = @base_url + path

      get(url)
    end

    # Ingests

    def ingests()
      path = "/ingests"
      url = @base_url + path

      get(url)
    end

    # Root

    def root()
      path = "/?oauth_token=#{@access_token}"
      url = @base_url + path

      get(url)
    end

    # Subscriptions

    def subscribed(channel_id, options = {})
      return false unless @access_token
      options[:oauth_token] = @access_token

      query = build_query_string(options)
      path = "/channels/#{channel_id}/subscriptions"
      url = @base_url + path + query

      get(url)
    end

    def subscribed_to_channel(user_id, channel_id)
      return false unless @access_token

      path = "/channels/#{channel_id}/subscriptions/#{user_id}?oauth_token=#{@access_token}"
      url = @base_url + path

      get(url)
    end
  end
end
