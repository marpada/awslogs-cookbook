# awslogs-agent-cookbook

Installs and configure awslogs-agent

## Supported Platforms

Tested on Ubuntu 14.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['awslogs-agent']['region']</tt></td>
    <td>String</td>
    <td>AWS region</td>
    <td><tt>us-east-1</tt></td>
  </tr>
  <tr>
    <td><tt>['awslogs-agent']['databag']</tt></td>
    <td>String</td>
    <td>Databag where the AWS credentials are stored</td>
    <td><tt>nil-east-1</tt></td>
  </tr>
  <tr>
    <td><tt>['awslogs-agent']['version']</tt></td>
    <td>String</td>
    <td>Version of the awslogs-cwlogs pip package</td>
    <td><tt>1.3.1</tt></td>
  </tr>
  <tr>
    <td><tt>['awslogs-agent']['streams']</tt></td>
    <td>String</td>
    <td>Logs streams to be pushed</td>
    <td><tt>{}</tt></td>
  </tr>
  <tr>
    <td><tt>['awslogs-agent']['path']</tt></td>
    <td>String</td>
    <td>Installation path</td>
    <td><tt>/var/awslogs</tt></td>
  </tr>
  <tr>
    <td><tt>['awslogs-agent']['plugin_url']</tt></td>
    <td>String</td>
    <td>Location to download awslogs-cwlogs from</td>
    <td><tt>http://aws-cloudwatch.s3-website-us-east-1.amazonaws.com</tt></td>
  </tr>
</table>

## Usage

### awslogs-agent::default

Include `awslogs-agent` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[awslogs-agent::default]"
  ]
}
```

The creation of log streams is attribute-driven using the
node['awslogs_agent']['streams'] hash.
For example
to push the /var/log/syslog:
```json
      "awslogs_agent": {
        "streams": {
          "syslog": {
            "file": '/var/log/syslog',
            "log_group_name": '/var/log/syslog',
            "datetime_format": '%Y-%m-%d %H:%M:%S',
            "log_stream_name": '{instance_id}',
          }
```

To read AWS credentials from a databag set the
node['awslogs_agent']['databag'], and create an item like:

```json
{
  "id": "main",
  "aws_access_key_id": "YOUR_ACCESS_KEY",
  "aws_secret_access_key": "YOUR_SECRET_ACCESS_KEY",
  "aws_session_token": "YOUR_SESSION_TOKEN"
}
```

Usage of AWS credentials is hightly discourage thought, and using a IAM
role is the recommended solution.

## License and Authors

Author:: YOUR_NAME (<YOUR_EMAIL>)
