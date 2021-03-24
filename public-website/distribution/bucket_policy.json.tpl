{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ${read_only_principals}
      },
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": [
        "arn:${partition}:s3:::${bucket_name}",
        "arn:${partition}:s3:::${bucket_name}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ${read_write_principals}
      },
      "Action": [
        "s3:Get*",
        "s3:List*",
        "s3:PutObject*"
      ],
      "Resource": [
        "arn:${partition}:s3:::${bucket_name}",
        "arn:${partition}:s3:::${bucket_name}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": ${write_only_principals}
      },
      "Action": [
        "s3:PutObject*"
      ],
      "Resource": [
        "arn:${partition}:s3:::${bucket_name}",
        "arn:${partition}:s3:::${bucket_name}/*"
      ]
    }
  ]
}
