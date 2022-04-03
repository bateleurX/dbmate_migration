terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.8.0"
    }
  }
}

# https://circleci.com/docs/2.0/openid-connect-tokens/
resource "aws_iam_openid_connect_provider" "CircleCI" {
  url             = "https://oidc.circleci.com/org/${var.cci_org_id}"
  thumbprint_list = ["${var.thumbprint_list}"]
  client_id_list  = ["${var.cci_org_id}"]
}


resource "aws_iam_role" "CircleCI_OIDC" {
  name = "CircleCIOIDCRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = [aws_iam_openid_connect_provider.CircleCI.arn]
      }
      Condition = {
        StringLike = {
          "oidc.circleci.com/org/${var.cci_org_id}:sub" = [
            "org/${var.cci_org_id}/project/${var.cci_project_id}/user/*",
          ]
        }
      }
    }]
  })
}

resource "aws_iam_policy" "CircleCI_policy" {
  name        = "CircleCI-Schemaspy"
  description = "CircleCI deploy policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject",
                "cloudfront:CreateInvalidation"
            ],
            "Resource": [
                "arn:aws:s3:::${var.aws_bucket_name}",
                "arn:aws:s3:::*/*",
                "arn:aws:cloudfront::${var.aws_project_id}:distribution/${var.aws_distribution_id}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "CircleCI_attachment" {
  role       = aws_iam_role.CircleCI_OIDC.name
  policy_arn = aws_iam_policy.CircleCI_policy.arn
}
