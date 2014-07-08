check-opsworks-deploy
=====================

This script is sensu plugin.

The check-opsworks-deploy plugin checks the deploy status on Opsworks.

## usage

### check application deploy status
```
ruby check-opsworks-deploy.rb --app_id your-app-id
```

### check stack applications deploy status

```
ruby check-opsworks-deploy.rb --stack_id your-stack-id
```

If you want to know deploy is runninng, use "--warn-at-running" option.
When this option is specified, script notify warning at the deploy status is "running".
