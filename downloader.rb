require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/drive_v3'

TEAM_DRIVE_ID = "0AEJpBZKnwJBQUk9PVA"

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

token_store_file = File.expand_path('.credential/credentials.yaml', __dir__)
scope = "https://www.googleapis.com/auth/drive"
client_id = Google::Auth::ClientId.from_file(File.expand_path('.credential/client_secret.json', __dir__))

token_store = Google::Auth::Stores::FileTokenStore.new(file: token_store_file)
authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store)

credentials = authorizer.get_credentials('default')
if credentials.nil?
  url = authorizer.get_authorization_url(base_url: OOB_URI)
  puts "Open #{url} in your browser and enter the resulting code:"
  code = $stdin.gets
  credentials = authorizer.get_and_store_credentials_from_code(user_id: 'default', code: code, base_url: OOB_URI)
end
service = Google::Apis::DriveV3::DriveService.new
service.authorization = credentials

file_list = service.list_files(
        corpora: 'teamDrive',
        team_drive_id: TEAM_DRIVE_ID,
	q: "name='#{ARGV[0]}.tar.xz'",
	spaces: 'drive',
        fields: 'files(id,trashed)',
        include_team_drive_items: true,
        supports_team_drives: true)



