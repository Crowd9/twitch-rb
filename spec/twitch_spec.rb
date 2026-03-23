require 'spec_helper'

describe Twitch do

  before(:each) do
    stub_request(:any, /api\.twitch\.tv/).to_return do |request|
      body = if request.uri.path =~ /\/streams\/featured/
        if request.uri.query.to_s =~ /limit=100/
          JSON.generate({ "featured" => Array.new(26, {}) })
        else
          JSON.generate({ "featured" => Array.new(25, {}) })
        end
      else
        '{}'
      end
      # /channels/followed returns 404 when the user is not following
      status = request.uri.path =~ /\/channels\/followed/ ? 404 : 200
      { status: status, body: body, headers: { 'Content-Type' => 'application/json' } }
    end
  end

  let(:client) { Twitch.new }

  it 'should build accurate link' do
    t = Twitch.new(
      client_id:    "abc",
      redirect_uri: "http://localhost:3000/auth",
      scope:        ["user_read", "channel_read"]
    )
    expect(t.link).to eq "https://id.twitch.tv/oauth2/authorize?response_type=code&client_id=abc&redirect_uri=http://localhost:3000/auth&scope=user_read+channel_read+"
  end

  # User

  it 'should get user by login name' do
    client.user("day9")
    expect(a_request(:get, "https://api.twitch.tv/helix/users/day9")).to have_been_made
  end

  it 'should not fetch authenticated user when unauthenticated' do
    expect(client.user).to eq false
  end

  it 'should get user when authenticated' do
    skip 'requires a valid access token'
  end

  it 'should get authenticated user' do
    skip 'requires a valid access token'
  end

  # Teams

  it 'should get all teams' do
    client.teams
    expect(a_request(:get, "https://api.twitch.tv/helix/teams/")).to have_been_made
  end

  it 'should get single team' do
    client.team("eg")
    expect(a_request(:get, "https://api.twitch.tv/helix/teams/eg")).to have_been_made
  end

  # Channel

  it 'should get single channel' do
    client.channel("day9tv")
    expect(a_request(:get, "https://api.twitch.tv/helix/channels/day9tv")).to have_been_made
  end

  it 'should get channel panels from the alt API base' do
    client.channel_panels("esl_csgo")
    expect(a_request(:get, "https://api.twitch.tv/api/channels/esl_csgo/panels")).to have_been_made
  end

  it 'should not fetch own channel without an access token' do
    expect(client.channel).to eq false
  end

  it 'should get your channel' do
    skip 'requires a valid access token'
  end

  it 'should edit your channel' do
    skip 'requires a valid access token'
  end

  # Streams

  it 'should get a single user stream' do
    client.stream("nasltv")
    expect(a_request(:get, "https://api.twitch.tv/helix/streams/nasltv")).to have_been_made
  end

  it 'should get all streams' do
    client.streams
    expect(a_request(:get, "https://api.twitch.tv/helix/streams")).to have_been_made
  end

  it 'should encode spaces as + in stream game filter' do
    client.streams(game: "League of Legends")
    expect(a_request(:get, "https://api.twitch.tv/helix/streams?game=League+of+Legends")).to have_been_made
  end

  it 'should pass pre-encoded + through in stream game filter' do
    client.streams(game: "League+of+Legends")
    expect(a_request(:get, "https://api.twitch.tv/helix/streams?game=League+of+Legends")).to have_been_made
  end

  it 'should get featured streams' do
    res = client.featured_streams
    expect(a_request(:get, "https://api.twitch.tv/helix/streams/featured")).to have_been_made
    expect(res[:body]["featured"].length).to eq 25
  end

  it 'should pass options to featured streams' do
    res = client.featured_streams(limit: 100)
    expect(a_request(:get, "https://api.twitch.tv/helix/streams/featured?limit=100")).to have_been_made
    expect(res[:body]["featured"].length).to be > 25
  end

  it 'should not fetch followed streams without an access token' do
    expect(client.followed_streams).to eq false
  end

  # Games

  it 'should get top games' do
    client.top_games
    expect(a_request(:get, "https://api.twitch.tv/helix/games/top")).to have_been_made
  end

  # Chat

  it 'should get chat links' do
    client.chat_links("day9tv")
    expect(a_request(:get, "https://api.twitch.tv/helix/chat/day9tv")).to have_been_made
  end

  it 'should get chat badges' do
    client.badges("day9tv")
    expect(a_request(:get, "https://api.twitch.tv/helix/chat/day9tv/badges")).to have_been_made
  end

  it 'should get chat emoticons' do
    client.emoticons
    expect(a_request(:get, "https://api.twitch.tv/helix/chat/emoticons")).to have_been_made
  end

  # Follows

  it 'should get channel followers using from_id' do
    client.following("day9tv")
    expect(a_request(:get, "https://api.twitch.tv/helix/users/follows?from_id=day9tv")).to have_been_made
  end

  it 'should paginate channel followers' do
    client.following("day9tv", offset: 25, limit: 25)
    expect(a_request(:get, "https://api.twitch.tv/helix/users/follows?offset=25&limit=25&from_id=day9tv")).to have_been_made
  end

  it 'should get channels followed by user using to_id' do
    client.followed("day9")
    expect(a_request(:get, "https://api.twitch.tv/helix/users/follows?to_id=day9")).to have_been_made
  end

  it 'should paginate channels followed by user' do
    client.followed("day9", offset: 25, limit: 25)
    expect(a_request(:get, "https://api.twitch.tv/helix/users/follows?offset=25&limit=25&to_id=day9")).to have_been_made
  end

  it 'should return 404 when user does not follow channel' do
    res = client.follow_status("day9", "day9tv")
    expect(a_request(:get, "https://api.twitch.tv/helix/channels/followed?user_id=day9&broadcaster_id=day9tv")).to have_been_made
    expect(res[:response]).to eq 404
  end

  it 'should not fetch followed videos without an access token' do
    expect(client.followed_videos).to eq false
  end

  # Videos

  it 'should get top videos' do
    client.top_videos
    expect(a_request(:get, "https://api.twitch.tv/helix/videos/top")).to have_been_made
  end

  # Misc

  it 'should get ingests' do
    client.ingests
    expect(a_request(:get, "https://api.twitch.tv/helix/ingests")).to have_been_made
  end

  it 'should get root' do
    client.root
    expect(a_request(:get, "https://api.twitch.tv/helix/")).to have_been_made
  end

  # Adapter

  it 'should have a default adapter' do
    expect(Twitch.new.adapter).to eq(Twitch::Adapters::HTTPartyAdapter)
  end

  it 'should work with a different adapter (open-uri)' do
    require 'helpers/open_uri_adapter'
    t = Twitch.new adapter: Twitch::Adapters::OpenURIAdapter
    res = t.featured_streams
    expect(res[:response]).to eq 200
    expect(res[:body]["featured"].length).to eq 25
  end

  it 'should fall back to the default adapter when passed an invalid adapter' do
    expect(Twitch.new(adapter: false        ).adapter).to eq(Twitch::Adapters::DEFAULT_ADAPTER)
    expect(Twitch.new(adapter: 100          ).adapter).to eq(Twitch::Adapters::DEFAULT_ADAPTER)
    expect(Twitch.new(adapter: :bad_constant).adapter).to eq(Twitch::Adapters::DEFAULT_ADAPTER)

    t = Twitch.new
    t.adapter = nil
    expect(t.adapter).to eq(Twitch::Adapters::DEFAULT_ADAPTER)
  end

  it 'should provide required Client-Id header each request' do
    Twitch.new(client_id: "test").featured_streams
    expect(a_request(:get, "https://api.twitch.tv/helix/streams/featured").
      with(headers: { 'Client-ID' => 'test' })).to have_been_made
  end

end
