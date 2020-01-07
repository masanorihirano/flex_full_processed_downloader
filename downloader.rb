require 'googleauth'
require 'google/apis/drive_v3'
require 'googleauth/stores/file_token_store'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

CLIENT_SECRETS_PATH = File.expand_path("./.credential/config.json",__dir__)
SCOPE = 'https://www.googleapis.com/auth/drive'
TEAM_DRIVE_ID = "0AEJpBZKnwJBQUk9PVA"
TOKEN_PATH = File.expand_path("./.credential/tokens.yaml",__dir__)
client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
token_store = Google::Auth::Stores::FileTokenStore.new(:file => TOKEN_PATH)
authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
credentials = authorizer.get_credentials(client_id)

if credentials.nil?
  url = authorizer.get_authorization_url(base_url: OOB_URI )
  puts "Open #{url} in your browser and enter the resulting code:"
  code = gets
  credentials = authorizer.get_and_store_credentials_from_code(
    user_id: user_id, code: code, base_url: OOB_URI)
end



