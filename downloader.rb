require "test/unit/assertions"
include Test::Unit::Assertions
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/drive_v3'
require "date"
require 'zlib'
require 'archive/tar/minitar'
require 'concurrent'
require "fileutils"

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

time0 = DateTime.now
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
service.get_file(file_id, download_dest:save_path)
time2 = DateTime.now
puts "#{time2.strftime('%Y/%m/%d %H:%M:%S')} File Download (#{ARGV[0]}) Ended"
file_size = File.size(save_path)*1.0/(1024*1024)
download_time = (time2-time1)*24*60*60
mbps = file_size/download_time
puts "#{ARGV[0]}.tar.xz: #{sprintf("%.2f",file_size/1024)}GB, #{sprintf("%.2f",download_time.to_f)}sec., #{sprintf("%.2f",mbps.to_f)}MB/s"

time3 = DateTime.now
if ARGV.length == 1 then
	# all
	if true then
		# multi
		puts "#{time3.strftime('%Y/%m/%d %H:%M:%S')}: Extraction of #{ARGV[0]}.tar.xz started with multi thread"
		system("pixz -x #{ARGV[0]} < #{save_path} | tar x")
	else
		# single
		puts "#{time3.strftime('%Y/%m/%d %H:%M:%S')}: Extraction of #{ARGV[0]}.tar.xz started with single thread"
		system("tar -Jxvf #{save_path}")
	end
else
	# partial
	if ARGV[1] != "stat" then
		target = ""
		ARGV.slice(1..ARGV.length-1).each{|ticker|
				target << " "
				target << "#{ARGV[0]}/Full#{ticker}.csv"
				target << " "
				target << "#{ARGV[0]}/Full#{ticker}_#{ARGV[0]}.txt"
		}
		if File.exist?(File.expand_path("pixz-runtime", __dir__)) and ARGV.length-1 > 10 then
			# multi
			puts "#{time3.strftime('%Y/%m/%d %H:%M:%S')}: Partial extraction started with multi thread"
			system("echo '#{target}' | tr ' ' '\n' | sed -e '1d' | xargs -I {} -P #{Concurrent.processor_count} sh -c 'pixz -x {} < #{save_path} | tar x'")
		else
			# single
			puts "#{time3.strftime('%Y/%m/%d %H:%M:%S')}: Partial extraction started with single thread"
			system("tar xfv #{save_path}#{target}")
		end
	else
		#stat
		target = ""
		(10..99).each{|i|
			target << " "
			target << i.to_s
			target << "00-"
			target << i.to_s
			target << "99"
		}
		(100..999).each{|i|
			target << " "
			target << i.to_s
			target << "0-"
			target << i.to_s
			target << "9"
		}
		(1000..9999).each{|i|
			target << " "
			target << i.to_s
			target << "-"
			target << i.to_s
		}
		if true then
			# multi
			puts "#{time3.strftime('%Y/%m/%d %H:%M:%S')}: Partial extraction started with multi thread"
			system("echo '#{target}' | tr ' ' '\n' | sed -e '1d' | xargs -I {} -P #{Concurrent.processor_count} sh -c 'pixz -x #{ARGV[0]}/stat#{ARGV[0]}-{}.csv < #{save_path} 2>/dev/null | tar x > /dev/null 2>&1'")
		else
			# single
			puts "#{time3.strftime('%Y/%m/%d %H:%M:%S')}: Partial extraction started with single thread"
			system("tar xfv #{save_path}#{target}")
		end
	end
end
time4 = DateTime.now
extraction_time = (time4-time3)*24*60*60
puts "#{time4.strftime('%Y/%m/%d %H:%M:%S')}: Extraction (#{ARGV[0]}) ended\ntime: #{sprintf("%.2f",extraction_time.to_f)}sec."

FileUtils.rm(save_path)
time5 = DateTime.now
total_time = (time5 -time0)*24*60*60
puts "#{time5.strftime('%Y/%m/%d %H:%M:%S')}: All process (#{ARGV[0]}) ended\ntotal_time: #{sprintf("%.2f",total_time.to_f)}sec."

