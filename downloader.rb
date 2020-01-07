require "google_drive"

session = GoogleDrive::Session.from_config(File.expand_path("./.credential/config.json",__dir__))
