resource "aws_iam_role" "cross_account_role" {
  name               = "${var.resource_prefix}-crossaccount-role"
  tags               = var.tags
  assume_role_policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "AWS" : var.ex_databricks_account_id
          },
          "Condition" : {
            "StringEquals" : {
              "sts:ExternalId" : var.databricks_account_id
            }
          }
        }
      ]
    })
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.resource_prefix}-policy"
  role   = aws_iam_role.cross_account_role.id
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1403287045000",
      "Effect": "Allow",
      "Action": [
        "ec2:AssociateIamInstanceProfile",
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CancelSpotInstanceRequests",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeIamInstanceProfileAssociations",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInstances",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNatGateways",
        "ec2:DescribeNetworkAcls",
        "ec2:DescribePrefixLists",
        "ec2:DescribeReservedInstancesOfferings",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSpotInstanceRequests",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeSubnets",
        "ec2:DescribeVolumes",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeVpcs",
        "ec2:DetachVolume",
        "ec2:DisassociateIamInstanceProfile",
        "ec2:ReplaceIamInstanceProfileAssociation",
        "ec2:RequestSpotInstances",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:DescribeFleetHistory",
        "ec2:ModifyFleet",
        "ec2:DeleteFleets",
        "ec2:DescribeFleetInstances",
        "ec2:DescribeFleets",
        "ec2:CreateFleet",
        "ec2:DeleteLaunchTemplate",
        "ec2:GetLaunchTemplateData",
        "ec2:CreateLaunchTemplate",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:ModifyLaunchTemplate",
        "ec2:DeleteLaunchTemplateVersions",
        "ec2:CreateLaunchTemplateVersion",
        "ec2:AssignPrivateIpAddresses",
        "ec2:GetSpotPlacementScores"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:PutRolePolicy"
      ],
      "Resource": "arn:aws-us-gov:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot",
      "Condition": {
        "StringLike": {
          "iam:AWSServiceName": "spot.amazonaws.com"
        }
      }
    }
  ]
})
}

resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous, aws_iam_role_policy.this]

  create_duration = "30s"
}