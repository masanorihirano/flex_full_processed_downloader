# flex_full_processed_downloader

## Requirements
 - ruby + gem (Recommend: https://github.com/rbenv/rbenv )
 - libarchive 2.8 or later (if use of multi processing; set-up command is written in `setup-full.sh`)

## Set up
### If you want to use multi processing or faster extraction in extraction of archive file:
```
./setup-all.sh
```
### If you use this program only with single thread:
```
./setup.sh
```

## Usage
### If you want all tick data in one day:
```
ruby (/path/to/this-repository/)downloader.py [day, e.g., 20150105]
```

### If you want only some ticker of all data in one day:
```
ruby (/path/to/this-repository/)downloader.py [day] [tickers]
```
For example,
```
ruby ~/flex_full_processed_downloader/downloader.rb 20150105 1301 1305 1306 1308 1309 1311 1312 1313 1319 1320 1321 1322 1323 1324 1325 1326 1327 1328 1329
```

## Note that
 - If you use this program for the first time, it require authorization of Google API. Please follow the leads, and log in with account under the controll of __**socsim.org**__ with access right to the team drive named `flex_full_processed`.
 - Download take about 10 sec. under usual internet connection
 - Data extraction take about 5-10 min. with multi processors of usual computation resource
 - We strongly recommend the multi processing.
 - Extraction of limitted numbers of tickers is slower than all extraction
 - All extraction usually make about 200 GB data folder
 - Each data of tickers are under 10 GB at maximum

## Author
Masanori HIRANO (https://mhirano.jp/; b2018mhirano@socsim.org)
