test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

amazon:
  service: S3
  region: ap-northeast-1
  bucket: <%= Rails.application.credentials.s3_bucket %>
