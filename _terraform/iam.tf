variable "s3_bucket" {}

resource "aws_iam_role" "glue_execute" {
  name                  = "glue_execute"
  description           = "role for glue execute."
  assume_role_policy    = "${data.aws_iam_policy_document.assume_role.json}"
  force_detach_policies = true
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "glue.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket}/*",
    ]
  }
}

resource "aws_iam_policy_attachment" "glue_service_role" {
  name       = "glue_service_role"
  roles      = ["${aws_iam_role.glue_execute.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "s3_access" {
  role   = "${aws_iam_role.glue_execute.name}"
  policy = "${data.aws_iam_policy_document.s3_access.json}"
}
