require "test/unit/assertions"
include Test::Unit::Assertions
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/drive_v3'
require "date"
require 'zlib'
require 'archive/tar/minitar'

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

assert_equal(file_list.files.length, 1, message="Error in finding a file.")
file_id = file_list.files[0].id
save_path = File.expand_path("tmp/#{ARGV[0]}.tar.xz", __dir__)
time1 = DateTime.now
puts "#{time1.strftime('%Y/%m/%d %H:%M:%S')} File Download (#{ARGV[0]}) Started"
#service.get_file(file_id, download_dest:save_path)
time2 = DateTime.now
puts "#{time2.strftime('%Y/%m/%d %H:%M:%S')} File Download (#{ARGV[0]}) Ended"
file_size = File.size(save_path)/(1024*1024)
download_time = (time2-time1)*24*60*60
mbps = file_size/download_time
puts "#{ARGV[0]}.tar.xz: #{sprintf("%.2f",file_size/1024)}GB, #{sprintf("%.2f",download_time.to_f)}sec., #{sprintf("%.2f",mbps.to_f)}MB/s"

if ARGV.length == 1 then
	# all
	system("tar -xf #{save_path}")
else
	# partial
end
