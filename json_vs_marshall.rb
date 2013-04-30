require 'benchmark'

require 'yajl'
require 'oj'

HASH = {
  "avatar_url" => "https://secure.gravatar.com/avatar/8f4b861a5b83575337b98d144a4ef4ca?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png",
  "bio" => "The GitHub API Dude",
  "blog" => "blog.theamazingrando.com",
  "company" => nil,
  "created_at" => "2008-02-11T18:44:09Z",
  "email" => "psadauskas@gmail.com",
  "events_url" => "https://api.github.com/users/paul/events{/privacy}",
  "followers" => 39,
  "followers_url" => "https://api.github.com/users/paul/followers",
  "following" => 2,
  "following_url" => "https://api.github.com/users/paul/following",
  "gists_url" => "https://api.github.com/users/paul/gists{/gist_id}",
  "gravatar_id" => "8f4b861a5b83575337b98d144a4ef4ca",
  "hireable" => false,
  "html_url" => "https://github.com/paul",
  "id" => 184,
  "location" => "Boulder, CO",
  "login" => "paul",
  "name" => "Paul Sadauskas",
  "organizations_url" => "https://api.github.com/users/paul/orgs",
  "public_gists" => 326,
  "public_repos" => 87,
  "received_events_url" => "https://api.github.com/users/paul/received_events",
  "repos_url" => "https://api.github.com/users/paul/repos",
  "starred_url" => "https://api.github.com/users/paul/starred{/owner}{/repo}",
  "subscriptions_url" => "https://api.github.com/users/paul/subscriptions",
  "type" => "User",
  "updated_at" => "2013-04-30T11:42:58Z",
  "url" => "https://api.github.com/users/paul"
}

MARSHAL_STRING = Marshal.dump(HASH)
JSON_STRING    = Yajl::Encoder.encode(HASH)

require 'benchmark/ips'

Benchmark.ips do |x|

  x.report("Encode: Marshal") { Marshal.dump(HASH) }
  x.report("Encode: Yajl")    { Yajl::Encoder.encode(HASH) }
  x.report("Encode: OJ")      { Oj.dump(HASH) }

  x.report("Decode: Marshal") { Marshal.load(MARSHAL_STRING) }
  x.report("Decode: Yajl")    { Yajl::Parser.parse(JSON_STRING) }
  x.report("Decode: OJ")      { Oj.load(JSON_STRING) }

end
