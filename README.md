# flex_full_processed_downloader

## Requirements
 - ruby + gem + bundler (Recommend: https://github.com/rbenv/rbenv )
 - pixz

## Set up
At first, install pixz.

For max
```
brew install pixz
```

For linux
```
sudo apt install pixz
```
or build using https://github.com/vasi/pixz

Then,
```
./setup.sh
```

## Usage
### If you want all tick data in one day:
```
ruby (/path/to/this-repository/)downloader.rb [day, e.g., 20150105]
```

When you use this for the first time, you will face the google authentication.
After login to google account ending with socsim.org, you will be redirect to localhost url that is not working.
In the localhost url, there are code which is necessary for authentication is exist.
http://localhost/oauth2callback?code={code is here}&scope=https://www.googleapis.com/auth/drive

### If you want only some ticker of all data in one day:
```
ruby (/path/to/this-repository/)downloader.rb [day] [tickers]
```
For example,
```
ruby ~/flex_full_processed_downloader/downloader.rb 20150105 1301 1305 1306 1308 1309 1311 1312 1313 1319 1320 1321 1322 1323 1324 1325 1326 1327 1328 1329
```

### If you want only status files in original processing, which contain daily indices
```
ruby (/path/to/this-repository/)downloader.rb [day] stat
```

## Note that
 - If you use this program for the first time, it require authorization of Google API. Please follow the leads, and log in with account under the controll of __**socsim.org**__ with access right to the team drive named `flex_full_processed`.
 - Download take about 10 sec. under usual internet connection
 - Data extraction take about 5-10 min. with multi processors of usual computation resource
 - Extraction of limitted numbers of tickers is slower than all extraction
 - All extraction usually make about 200 GB data folder
 - Each data of tickers are under 10 GB at maximum

## Author
Masanori HIRANO (https://mhirano.jp/; b2018mhirano@socsim.org)
