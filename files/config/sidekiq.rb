---
:concurrency: 5
staging:
  :concurrency: 5
production:
  :concurrency: 10
:queues:
  - critical
  - default
  - low
