pantry_import_aws_bill_command
==============================

It gets the billing CSV file, parses it and it updates the total cost in Pantry. To run this daemon in development use this command:

```
ENVIRONMENT=development bundle exec ./daemon.rb run
```