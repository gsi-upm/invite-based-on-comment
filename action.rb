require "octokit"
require "json"

# Each Action has an event passed to it.
event = JSON.parse(File.read(ENV['GITHUB_EVENT_PATH']))
comment = event["comment"]["body"]
org = ENV['ORG']
team_id = ENV['TEAM_ID']
commenter = event["comment"]["user"]["login"]
self_invite = defined?(ENV['SELF_INVITE']) == nil ? true : ENV['SELF_INVITE']
invite_existing = defined?(ENV['INVITE_EXISTING']) == nil ? true : ENV['INVITE_EXISTING']

puts "-------------------------------------------------"

# Use GITHUB_TOKEN to interact with the GitHub API
client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])

if comment.include?(".invite") && comment.split().length == 2
  cmd, handle = comment.split


  user = ( handle == "me" && self_invite ? commenter : handle.tr('@', '') )
  puts "USER: #{user}"
  
  if ( user == commenter ) && self_invite 
    puts "Self-inviting is not enabled"
    exit(78) 
  end
  
  if client.organization_member?(org, user) && invite_existing
    puts "User is already a member of the organization, and inviting existing members is not enabled."
    exit(99) 
  end
  
  client.add_team_membership(team_id, user)
end

puts "-------------------------------------------------"

puts "Action succesfully ran"
