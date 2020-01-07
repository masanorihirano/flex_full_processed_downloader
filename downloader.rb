require "google_drive"

p File.expand_path("./.credential/config.json",__dir__)
session = GoogleDrive::Session.from_config(File.expand_path("./.credential/config.json",__dir__))
