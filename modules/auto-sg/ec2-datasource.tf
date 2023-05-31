# data "aws_instances" "this" {
#   filter {
#     name   = "tag:${var.lb_target_tags_map["name"]}"
#     values = ["${var.lb_target_tags_map["value"]}"]
#   }
# }

# output "data_aws_instance_id" {
#   value       = concat(data.aws_instances.this.*.id, [""])[0]
#   description = "data_aws_instance_id"
# }

# output "data_aws_instance_ids" {
#   value       = concat(data.aws_instances.this.*.ids, [""])[0]
#   description = "data_aws_instance_ids"
# }